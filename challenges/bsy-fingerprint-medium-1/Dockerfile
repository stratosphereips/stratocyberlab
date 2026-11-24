FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends python3 redis-server redis-tools curl && rm -rf /var/lib/apt/lists/*
WORKDIR /opt/challenge
COPY service.py /opt/challenge/service.py
ENTRYPOINT ["python3", "/opt/challenge/service.py"]
