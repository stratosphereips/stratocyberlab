FROM debian:bookworm

# for local rebuilds during dev, download the deb outside the container and use this instead of the wget:
#COPY webmin_1.920_all.deb /tmp

WORKDIR /tmp

RUN <<EOF
apt-get update
apt-get install -y wget perl libnet-ssleay-perl libauthen-pam-perl libio-pty-perl apt-show-versions python3 iptables iproute2 nmap openssh-client curl
# comment this line for local dev:
wget -q https://downloads.sourceforge.net/project/webadmin/webmin/1.920/webmin_1.920_all.deb
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

COPY poem.txt /app/

WORKDIR /app
# these iptables rules don't matter - they are just here so that there is a justification for this device at all
COPY init.sh /app/
CMD bash init.sh
