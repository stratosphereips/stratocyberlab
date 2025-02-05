# Forgot Your Password

Web security, application vulnerability exploitation (including coding).

## How to solve

Follow the instructions in the attached autosolver application.

TLDR:

1. Run a reverse shell listener in the hackerlab
2. Run [an HTTP server](./auto-solve/ldap-server/src/main/java/PayloadHTTPServer.java) (also in the hackerlab) to host a [class that will launch a reverse shell](./auto-solve/Exploit.java) connection to the listener from the previous step
3. Run [an LDAP server](./auto-solve/ldap-server/src/main/java/LDAPRefServer.java) (still in the hackerlab) to point to the hosted class from the previous step
4. [Post a payload](./auto-solve/ldap-server/src/main/java/Launcher.java) to the Java app running at `/auth/*` to exploit CVE-2021-44228 and point to the LDAP server from the previous step
5. Through the reverse shell, explore the machine and the network
6. From the sources of the application the reverse shell is running through (JAR located in `/app/`), extract a HMAC256 JWT signing secret
7. Find a `mailus` suffering from CVE-2021-42013, allowing an attacker to read `/etc/shadow`
8. Reuse the same credentials to SSH into `logus` and extract a user ID from `/var/log/dashboard/proxy2021-12-09.log`
9. Forge a JWT with containing simply the user ID, and sign it with the signing secret
10. Access the dashboard (repository) and copy and submit the flag
