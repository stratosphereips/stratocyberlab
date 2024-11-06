FROM alpine:latest

RUN apk update && apk add --no-cache vsftpd openssh-server

RUN mkdir -p /var/run/sshd
RUN mkdir -p /root/.ssh

RUN echo "root:admin" | chpasswd

# Create a directory for the FTP user and add lorem ipsum files
RUN mkdir -p /home/pepitto/files
RUN echo "TODO: this is some publicly available content (not secret)" > /home/pepitto/files/todo.txt
RUN echo "TODO: Ooh no, this was suppsed to be secret" > /home/pepitto/files/secret.txt

# Create the FTP user and set a password
RUN adduser -D pepitto && echo "pepitto:Hard2GuessP@ssw0rd!" | chpasswd

# Set permissions for the FTP user's directory
RUN chown -R pepitto:pepitto /home/pepitto/files

# Copy the vsftpd configuration file into the container
COPY vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY sshd_config /etc/ssh/sshd_config
COPY start.sh /start.sh

# Expose FTP port and passive port range
EXPOSE 21 40000-50000

# Start vsftpd
CMD ["/start.sh"]