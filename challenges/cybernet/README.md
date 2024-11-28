# Cybernet

This challenge is about understanding of a C&C protocol. Students are given an IP address where a simple TCP C&C server
is hosted. Students should implement a client to fulfil all the servers' commands to eventually receive a flag.

## How to solve
<details>
  <summary>Click to reveal how to solve steps</summary>

TODO: write proper how to solve steps in more detail

1. First, we find the port of the server using nmap and try to connect
```bash
root@hackerlab:~# nmap 172.20.0.52
Starting Nmap 7.93 ( https://nmap.org ) at 2024-11-26 22:46 UTC
Nmap scan report for scl-challenge-cybernet.playground-net (172.20.0.52)
Host is up (0.0000060s latency).
Not shown: 999 closed tcp ports (reset)
PORT     STATE SERVICE
4444/tcp open  krb524
MAC Address: 02:42:AC:14:00:34 (Unknown)

Nmap done: 1 IP address (1 host up) scanned in 0.27 seconds
root@hackerlab:~# nc 172.20.0.52 4444

            _                          _   
  ___ _   _| |__   ___ _ __ _ __   ___| |_ 
 / __| | | | '_ \ / _ \ '__| '_ \ / _ \ __|
| (__| |_| | |_) |  __/ |  | | | |  __/ |_ 
 \___|\__, |_.__/ \___|_|  |_| |_|\___|\__|
      |___/                                



<CyberNet Master> What do you want to do?
1 - Join
2 - Get a command
3 - Get a flag
4 - Quit
```

2. After that, we should interact with the server to understand its mechanism and all possible commands that proper bots should implement. One example of a working bot client implemented in Python is given below. If ran, it fulfils all servers' tasks and prints the flag
```python3
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
```

</details>

## Testing

The script [auto-solve.sh](./auto-solve.sh) automatically verifies that the challenge can be solved.
