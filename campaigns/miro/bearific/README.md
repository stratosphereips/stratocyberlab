# Bearific

This challenge focuses on understanding how attackers interact with honeypots.
Students will configure Cowrie, a medium-interaction SSH honeypot, to monitor and log attacker activity:
an automated attacker script connects to the target machine (`victim`) and attempts to detect if the system is a honeypot by checking for inconsistencies.
It gives pointers to the student to perform additional configuration steps to reduce the honeypot-ness of the victim machine.

## Skills Used

1. **SSH Protocol Understanding**: Students must understand basics of how SSH works, including authentication mechanisms and common attack vectors, such as brute-forcing credentials).
1. **Honeypot Recognition**: Students need to identify signs that a system is a honeypot, such as unusual hostnames, file system inconsistencies, and network anomalies.
1. **Linux Command Line Proficiency**: Students should detect the use of and understand the basic behavior of commands such as `hostname`, `uname`, `ping`, `find`, `ls`, and `cat` to investigate the system.
1. **Privilege Escalation Awareness**: The challenge involves checking for SUID binaries to exploit potential vulnerabilities.

## Learning Objectives

- Understand how common honeypots like Cowrie work to detect and log attacker activity.
- Recognize common signs that a system might be a honeypot.
- See how Linux commands can be used to investigate a system for anomalies.

## How to solve

<details>
  <summary>Click to reveal how to solve steps</summary>
1. SSH into the `172.20.0.202` victim machine using root:alpine
2. Install and run cowrie on port 2222
3. Follow attacker's comments (using `playlog`) and implement requested functionality until flag is deposited into `/root/.flag`
4. Submit flag
</details>
