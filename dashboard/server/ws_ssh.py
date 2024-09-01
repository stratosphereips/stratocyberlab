import eventlet
eventlet.monkey_patch()

from typing import List, Tuple
from flask import Flask, request
from flask_socketio import SocketIO, emit, disconnect
import paramiko
import threading
import sys
import socket

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


app = Flask(__name__)
socketio = SocketIO(app, async_mode='eventlet', cors_allowed_origins='*')

clients = {}  # Store SSH clients and channels by session ID

def manage_ssh_output(ssh_channel, sid):
    """Thread function to handle incoming data from the SSH server."""
    try:
        while True:
            data = ssh_channel.recv(1024)
            if not data:
                break
            socketio.emit('ssh_output', data, to=sid)
    except Exception as e:
        eprint(f"SSH read error for session {sid}: {e}")
        socketio.emit('ssh_output', f'SSH read error: {e}', to=sid)
        disconnect(sid)

def start_ssh_session(sid):
    """Establish SSH connection and manage communication."""
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh_client.connect(hostname="172.20.0.2", username="root", password="ByteThem123", port=22)
        channel = ssh_client.invoke_shell(term='xterm-256color')
        clients[sid] = {'client': ssh_client, 'channel': channel}

        # Start a thread to read from SSH server
        thread = threading.Thread(target=manage_ssh_output, args=(channel, sid))
        thread.daemon = True
        thread.start()
    except Exception as e:
        eprint(f"SSH connection error for session {sid}: {e}")
        socketio.emit('ssh_output', f'SSH connection error: {e}', to=sid)
        disconnect(sid)

@socketio.on('connect')
def handle_connect():
    start_ssh_session(request.sid)

@socketio.on('ssh_input')
def handle_ssh_input(data):
    """Send command to SSH server."""
    sid = request.sid
    if sid in clients:
        try:
            clients[sid]['channel'].send(data)
        except socket.error as e:
            if str(e) == "Socket is closed":
                eprint(f"Socket closed for session {sid}: {e}")
            else:
                raise  # re-raise the exception if it's not the "Socket is closed" error

@socketio.on('ssh_resize')
def handle_ssh_resize(data):
    sid = request.sid
    if sid in clients:
        try:
            rows, cols = data["rows"], data["cols"]
            clients[sid]['channel'].resize_pty(width=cols, height=rows)
        except Exception as e:
            eprint(f"Error resizing terminal: {e}")

@socketio.on('disconnect')
def handle_disconnect():
    """Close SSH connection on client disconnect."""
    sid = request.sid
    if sid in clients:
        clients[sid]['client'].close()
        del clients[sid]
    eprint(f'Client {sid} disconnected')


if __name__ == '__main__':
    socketio.run(app, debug=True, host='0.0.0.0', port=8080)
