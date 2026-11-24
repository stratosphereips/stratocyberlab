FROM python:3.12-slim
WORKDIR /opt/challenge
RUN pip install --no-cache-dir pyftpdlib==2.0.1 && mkdir -p /srv/ftp/public /srv/ftp/real && chmod -R a+rX /srv/ftp
COPY server.py /opt/challenge/server.py
COPY assets/roster.txt /srv/ftp/public/roster.txt
COPY assets/real/relay.log /srv/ftp/real/relay.log
CMD ["python3", "/opt/challenge/server.py"]
