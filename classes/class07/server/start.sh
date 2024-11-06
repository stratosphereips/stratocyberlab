#!/bin/sh

ssh-keygen -A
/usr/sbin/sshd

/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf