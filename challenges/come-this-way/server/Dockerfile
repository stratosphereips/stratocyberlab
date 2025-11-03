FROM ubuntu:24.04

RUN apt update && apt install -y vsftpd openssh-server

# Create a directory for the FTP user and add lorem ipsum files
RUN mkdir -p /home/pepitto/files
COPY files/content.txt files/secret.txt /home/pepitto/files/

# Create the FTP user and set a password
RUN useradd -m -d /home/pepitto -s /bin/bash pepitto && echo "pepitto:Hard2GuessP@ssw0rd!" | chpasswd

# Set permissions for the FTP user's directory
RUN chown -R pepitto:pepitto /home/pepitto/files

# Copy the vsftpd configuration file into the container
COPY vsftpd.conf /etc/vsftpd/vsftpd.conf

# Start vsftpd
CMD ["/usr/sbin/vsftpd", "/etc/vsftpd/vsftpd.conf"]