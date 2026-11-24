FROM debian:bookworm-slim
ARG FLAG
ENV FLAG=${FLAG}
RUN apt-get update && apt-get install -y --no-install-recommends redis-server redis-tools python3 ca-certificates && rm -rf /var/lib/apt/lists/* && mkdir -p /opt/challenge
COPY service.py /opt/challenge/service.py
WORKDIR /opt/challenge
CMD ["python3", "/opt/challenge/service.py"]
