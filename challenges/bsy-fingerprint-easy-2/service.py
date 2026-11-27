import socket
import threading
from pathlib import Path

FTP_PORT = 21210
PASSIVE_PORT = 21211
DECOY_PORTS = (2200, 2323)
ARCHIVE = Path('/app/archive.txt')


def send_line(sock, text):
    sock.sendall((text + '\r\n').encode())


def control_session(conn):
    server_ip = conn.getsockname()[0]
    passive = None
    try:
        send_line(conn, '220 Last BBS Gateway FTP service ready')
        reader = conn.makefile('rb')
        while True:
            raw = reader.readline(4096)
            if not raw:
                break
            parts = raw.decode(errors='replace').strip().split(' ', 1)
            command = parts[0].upper()
            argument = parts[1] if len(parts) > 1 else ''

            if command == 'USER':
                send_line(conn, '331 Password required')
            elif command == 'PASS':
                send_line(conn, '230 Anonymous access granted')
            elif command == 'SYST':
                send_line(conn, '215 UNIX Type: L8')
            elif command == 'FEAT':
                send_line(conn, '211-Features')
                send_line(conn, ' UTF8')
                send_line(conn, '211 End')
            elif command in ('TYPE', 'OPTS', 'NOOP'):
                send_line(conn, '200 Command okay')
            elif command == 'PWD':
                send_line(conn, '257 \"/\" is the current directory')
            elif command == 'CWD':
                send_line(conn, '250 Directory changed')
            elif command == 'PASV':
                if passive:
                    passive.close()
                passive = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                passive.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                passive.bind(('0.0.0.0', PASSIVE_PORT))
                passive.listen(1)
                octets = server_ip.split('.')
                p1, p2 = divmod(PASSIVE_PORT, 256)
                address = ','.join(octets + [str(p1), str(p2)])
                send_line(conn, '227 Entering Passive Mode (%s)' % address)
            elif command in ('LIST', 'NLST', 'RETR'):
                if not passive:
                    send_line(conn, '425 Use PASV first')
                    continue
                if command == 'RETR' and argument.rsplit('/', 1)[-1] != 'ARCHIVE.TXT':
                    passive.close()
                    passive = None
                    send_line(conn, '550 File unavailable')
                    continue
                send_line(conn, '150 Opening data connection')
                try:
                    data, _ = passive.accept()
                    if command == 'RETR':
                        data.sendall(ARCHIVE.read_bytes())
                    elif command == 'NLST':
                        data.sendall(b'ARCHIVE.TXT\r\n')
                    else:
                        data.sendall(b'-rw-r--r-- 1 bbs bbs 64 Jan 01 00:00 ARCHIVE.TXT\r\n')
                    data.close()
                    send_line(conn, '226 Transfer complete')
                except OSError:
                    send_line(conn, '425 Data connection failed')
                finally:
                    passive.close()
                    passive = None
            elif command == 'QUIT':
                send_line(conn, '221 Goodbye')
                break
            else:
                send_line(conn, '502 Command not implemented')
    except (OSError, ConnectionError):
        pass
    finally:
        if passive:
            passive.close()
        try:
            conn.close()
        except OSError:
            pass


def ftp_listener():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('0.0.0.0', FTP_PORT))
    server.listen(32)
    while True:
        conn, _ = server.accept()
        threading.Thread(target=control_session, args=(conn,), daemon=True).start()


def decoy_listener(port):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('0.0.0.0', port))
    server.listen(16)
    while True:
        conn, _ = server.accept()
        try:
            conn.sendall(b'SSH-2.0-OpenSSH_9.6p1 Debian-1\r\n')
        except OSError:
            pass
        finally:
            conn.close()


threading.Thread(target=ftp_listener, daemon=True).start()
for decoy_port in DECOY_PORTS:
    threading.Thread(target=decoy_listener, args=(decoy_port,), daemon=True).start()
threading.Event().wait()
