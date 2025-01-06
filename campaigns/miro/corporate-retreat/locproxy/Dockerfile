FROM mitmproxy/mitmproxy:11.0.2

WORKDIR /app

RUN <<EOF
apt-get update
apt-get install -y iproute2 inetutils-ping curl
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -out ca.crt -addext keyUsage=critical,keyCertSign -subj '/CN=BigComp Root CA/C=DK/O=BigComp'
cat ca.key ca.crt > mitmproxy-ca.pem
mkdir -p /var/log/proxy/
EOF

# create a ssh 'backdoor'
RUN <<EOF
usermod -p '' root
sed -i '$a PermitRootLogin yes' /etc/ssh/sshd_config
sed -i '$a PermitEmptyPasswords yes' /etc/ssh/sshd_config
mkdir /run/sshd
EOF

COPY web-proxy-2025-01-05.log /var/log/proxy/

COPY init.sh /app
CMD bash /app/init.sh
