FROM python:3.12-alpine
WORKDIR /app
COPY http_service.py /app/http_service.py
COPY backup/rotation.txt /tmp/backup/rotation.txt
RUN mkdir -p /srv/www/snapshots && tar -czf /srv/www/snapshots/station-maintenance.tar.gz -C /tmp/backup rotation.txt && rm -rf /tmp/backup
CMD ["python3", "/app/http_service.py"]
