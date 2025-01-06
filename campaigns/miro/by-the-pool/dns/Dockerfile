FROM coredns/coredns:1.12.0

WORKDIR /app
COPY Corefile /app/
COPY bread.db /app/

ENTRYPOINT ["/coredns", "-conf", "/app/Corefile"]
