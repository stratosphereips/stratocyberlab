# Hello-world

## About

Simple initial challenge to verify that the environment is working correctly.

### Task
Find an HTTP server at IP address `172.20.0.3` and retrieve a flag.

**Recommended tools:**
* nmap
* curl

## How to solve
<details>
  <summary>Click to reveal how to solve steps</summary>

1. Use nmap to find opened ports:
```bash
root@hackerlab:~# nmap -sS -n -v 172.20.0.3   
Starting Nmap 7.93 ( https://nmap.org ) at 2024-03-20 08:57 UTC
Initiating ARP Ping Scan at 08:57
Scanning 172.20.0.3 [1 port]
Completed ARP Ping Scan at 08:57, 0.06s elapsed (1 total hosts)
Initiating SYN Stealth Scan at 08:57
Scanning 172.20.0.3 [1000 ports]
Discovered open port 8000/tcp on 172.20.0.3
Completed SYN Stealth Scan at 08:57, 0.03s elapsed (1000 total ports)
Nmap scan report for 172.20.0.3
Host is up (0.0000040s latency).
Not shown: 999 closed tcp ports (reset)
PORT     STATE SERVICE
8000/tcp open  http-alt
MAC Address: 02:42:AC:14:00:03 (Unknown)

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 0.20 seconds
           Raw packets sent: 1001 (44.028KB) | Rcvd: 1001 (40.032KB)
```

2. Discover opened port 8000 and try to send an HTTP request
```bash
root@hackerlab:~# curl 172.20.0.3:8000 
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hello world</title>
</head>
<body>
    Congratulations, you found a flag for the hello-world challenge. 
    Your setup seems to be working, happy hacking!
    
    bsy{simple-hello-world-flag}
</body>
</html>
```


</details>

## Testing
<details>
  <summary>Click for details</summary>


The script [auto-solve.sh](./auto-solve.sh) automatically verifies that the challenge can be solved.

</details>
