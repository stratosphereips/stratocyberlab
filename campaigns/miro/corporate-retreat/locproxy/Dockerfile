FROM mitmproxy/mitmproxy:11.0.2

WORKDIR /app

RUN <<EOF
apt-get update
apt-get install -y iproute2 inetutils-ping curl
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -out ca.crt -addext keyUsage=critical,keyCertSign -subj '/CN=BigComp Root CA/C=DK/O=BigComp'
cat ca.key ca.crt > mitmproxy-ca.pem
mkdir /var/proxy/
EOF

COPY init.sh /app
CMD bash /app/init.sh
