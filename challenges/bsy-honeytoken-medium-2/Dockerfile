FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-pyftpdlib && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY server.py /app/server.py
CMD ["python3", "/app/server.py"]
