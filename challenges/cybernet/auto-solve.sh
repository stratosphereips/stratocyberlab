#!/bin/bash

# Python client as a hardcoded string
PYTHON_CODE=$(cat << 'EOF'

import socket
import hashlib

def sendline_after(sock: socket.socket, prompt: bytes, line: bytes):
    while True:
        data = sock.recv(4096)
        if prompt in data:
            sock.sendall(line + b"\n")
            return


def recvline_startswith(sock: socket.socket, prefix: bytes) -> str:
    while True:
        data = sock.recv(4096)
        lines = data.splitlines()
        for line in lines:
            if line.startswith(prefix):
                return line.decode()


def join(sock: socket.socket):
    sendline_after(sock, b"Quit", b"1")

    prefix = '<CyberNet Master> To join you must prove you are a bot and calculate me '
    line = recvline_startswith(sock, prefix.encode())
    print(f"#### received challenge:\n{line}")

    expression = line[len(prefix):].strip()
    solution = str(eval(expression)) # yea I like living on the edge haha
    print(f"### sending solution:\n{solution}\n")
    sock.sendall(solution.encode() + b"\n")


def solve_command(line: str, local_ip: str) -> bytes:
    line = line.strip()
    if "Send me your machine's hostname." in line:
        return b"yea I am sure the master does not check this"

    elif line.startswith("<CyberNet Master> Send me a SHA-256 of this string '"):
        data = line[-21:-1]
        return hashlib.sha256(data.encode()).hexdigest().encode()

    elif line.startswith("<CyberNet Master> Send me a 2 digit country code for this place: '"):
        prefix = "<CyberNet Master> Send me a 2 digit country code for this place: '"
        place = line[len(prefix):-1]
        resp = {
            "Tokyo": "JP",
            "Stonehenge": "GB",
            "Machu Picchu": "PE",
            "The Shire": ""
        }[place]
        return resp.encode()

    else:
        raise Exception(f"unknown command '{line}'")


def do_commands(sock: socket.socket, local_ip: str, n: int = 10):
    for i in range(n):
        # Choose command
        sendline_after(sock, b"Quit", b"2")

        line = recvline_startswith(sock, b"<CyberNet Master>")
        print(f"### received command:\n{line}")

        answer = solve_command(line, local_ip)
        print(f"### sending answer:\n{answer}\n")
        sock.sendall(answer + b"\n")


def get_flag(sock: socket.socket):
    sendline_after(sock, b"Quit", b"3")

    prefix = "<CyberNet Master> Ok then, here is your flag "
    line = recvline_startswith(sock, prefix.encode())

    flag = line[len(prefix):]
    print(f"Got flag {flag}")
    return flag


def run(server_ip: str, port: int):
    with socket.create_connection((server_ip, port)) as sock:
        local_ip = sock.getsockname()[0]

        join(sock)
        do_commands(sock, local_ip, n=10)
        get_flag(sock)


if __name__ == "__main__":
    run(server_ip="172.20.0.52", port=4444)

EOF
)

# Specify the output Python file
OUTPUT_FILE="/tmp/auto-solve-cybernet.py"

echo "$PYTHON_CODE" > $OUTPUT_FILE
chmod +x $OUTPUT_FILE
MATCH=`python3 $OUTPUT_FILE | grep -o "BSY{eBhnIBKYNuHlaAKk2JhoDCBGJLJFogAk6uQ7gQxU89IADQGpe2ATVAbyagAg}"`
if [[ "$MATCH" == "" ]]
then
    echo "Error - the Python client did not manage to get the flag"
    exit 1
fi

# submit a flag in the submission server
RES=`curl -s 'http://172.20.0.3/api/challenges/submit' \
    -X POST \
    -H 'Content-Type: application/json' \
    --data-binary '{"challenge_id": "cybernet", "task_id": "task1", "flag" : "BSY{eBhnIBKYNuHlaAKk2JhoDCBGJLJFogAk6uQ7gQxU89IADQGpe2ATVAbyagAg}"}'`
if [[ $RES != *"Congratulations"* ]]; then
  echo "Failed to submit the flag - $RES"
  exit 2
fi


echo "OK - tests passed"
exit 0
