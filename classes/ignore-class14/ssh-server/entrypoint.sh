#!/bin/bash

# Start rsyslog
echo "Starting rsyslog..."
rsyslogd

# Start SSH server
echo "Starting sshd..."
/usr/sbin/sshd -D