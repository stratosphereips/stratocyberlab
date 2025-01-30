FROM ghcr.io/max-lt/nginx-jwt-module:v3.4.2
COPY nginx-default.conf /etc/nginx/conf.d/default.conf

RUN <<EOD
apk add iptables
echo "iptables -t nat -A POSTROUTING -j MASQUERADE --random" > /docker-entrypoint.d/40-iptables-forward.sh
chmod +x /docker-entrypoint.d/40-iptables-forward.sh
EOD
