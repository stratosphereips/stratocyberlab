FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends bind9 bind9-dnsutils && rm -rf /var/lib/apt/lists/*
COPY named.conf /etc/bind/named.conf
COPY db.bank.test /etc/bind/db.bank.test
RUN chown bind:bind /etc/bind/db.bank.test && named-checkconf -z /etc/bind/named.conf
