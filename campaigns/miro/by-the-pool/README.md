# By the Pool

This challenge focuses on analyzing metadata and exploiting weaknesses in secure systems.
Students will, from a user perspective, explore a hacking forum, where they uncover a conversation.
The challenge involves discovering a fatal flaw in an otherwise secure authentication system.
Furthermore, certain metadata is to be extracted from related files.

## Skills Used

1. **Network Scanning**: Students must scan the network to identify services (DNS, HTTP) and their IPs.
1. **Web Application Security**: Students log into a forum using credentials from a previous challenge, discover and exploit authentication vulnerabilities.
1. **Metadata Analysis**: Students extract metadata from an image using specialized tools.
1. **Brute-Force Attacks**: Students automate a brute-force attack after finding an attack vector.

## Learning Objectives

- Understand how to scan networks to discover services and their IPs.
- Learn to exploit weaknesses in authentication systems, such as brute-forcing.
- Practice extracting and analyzing metadata from files (e.g., images).
- Recognize the importance of rate-limiting and CSRF protection in securing web applications.

## How to solve

<details>
  <summary>Click to reveal how to solve steps</summary>
1. Scan the network to newly find one DNS, one HTTP server.
2. Access the HTTP server and log in with the credentials from the last 
   challenge.
3. Since the TOTP verification endpoint does not check against any CSRF and 
   does not ratelimit, you can easily bruteforce it, as is done in the
   [auto-solve](./auto-solve.sh)). This might take a few attempts, depending on
   how much of a performance penalty there is on your computer.
4. Access the user's private messages to find the tool's extension as the 
   answer to the first task.
5. Download the image attached by the logged-in user, subject it to
   `exiftool -n` and reveal the GPS coordinates where the photo was taken.
</details>
