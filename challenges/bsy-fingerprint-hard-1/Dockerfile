FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends redis-server redis-tools python3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/bbs
COPY entrypoint.sh /opt/bbs/entrypoint.sh
COPY decoys.py /opt/bbs/decoys.py
RUN chmod 0755 /opt/bbs/entrypoint.sh

CMD ["/opt/bbs/entrypoint.sh"]
