FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends mosquitto mosquitto-clients && rm -rf /var/lib/apt/lists/*
COPY mosquitto.conf /etc/mosquitto/mosquitto.conf
COPY start-relay.sh /usr/local/bin/start-relay.sh
RUN chmod 755 /usr/local/bin/start-relay.sh
ENTRYPOINT ["/usr/local/bin/start-relay.sh"]
