#!/bin/bash

# Start rsyslog
echo "Starting rsyslog..."
rsyslogd

# Start sshd
echo "Starting sshd..."
/usr/sbin/sshd -D