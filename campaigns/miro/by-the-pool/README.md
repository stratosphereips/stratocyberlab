# By the Pool

Metadata analysis, finding weaknesses in secure systems.

## How to solve

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
