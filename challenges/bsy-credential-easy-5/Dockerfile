FROM python:3.12-slim
WORKDIR /app
RUN pip install --no-cache-dir pyftpdlib
COPY server.py /app/server.py
COPY public /srv/ftp/public
COPY private /srv/ftp/private
RUN chmod -R a+rX /srv/ftp
USER 65534:65534
CMD ["python3", "/app/server.py"]
