FROM python:3-slim

ARG WWW_DIR=/var/www/hello-world/
WORKDIR $WWW_DIR

RUN mkdir -p $WWW_DIR
COPY index.html $WWW_DIR/

CMD ["python3", "-m", "http.server"]
