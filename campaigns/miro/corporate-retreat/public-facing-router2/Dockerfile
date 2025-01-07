FROM debian:bookworm

WORKDIR /tmp
RUN <<EOF
apt-get update
apt-get install -y wget perl libnet-ssleay-perl libauthen-pam-perl libio-pty-perl apt-show-versions python3 iptables iproute2 nmap openssh-client curl
# comment this line for local dev:
wget https://downloads.sourceforge.net/project/webadmin/webmin/1.920/webmin_1.920_all.deb
dpkg --force-all -i webmin_1.920_all.deb
# fix broken dependency on 'python' which no longer exists in the repos
sed -i 's/, python$//' /var/lib/dpkg/status
# allow password changing = enable CVE-2019-15107
sed -i 's/passwd_mode=0/passwd_mode=2/' /etc/webmin/miniserv.conf
rm -r /tmp/webmin*
EOF

# enable webmin to work
RUN <<EOF
mkdir /etc/network
touch /etc/network/interfaces
EOF

RUN <<EOF
apt-get install -y iptables ulogd2 openssh-server
mkdir /run/sshd
EOF

COPY ssh.log /var/log/ulog/syslogemu.log

WORKDIR /app
COPY init.sh /app
CMD bash init.sh
