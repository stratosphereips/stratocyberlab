FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-pyftpdlib && rm -rf /var/lib/apt/lists/*
WORKDIR /opt/challenge
COPY server.py /opt/challenge/server.py
COPY pub/ /srv/ftp/pub/
COPY settlement.txt /srv/ftp/real/settlement.txt
EXPOSE 21 30000-30010
CMD ["python3", "/opt/challenge/server.py"]
