FROM python:3.12-alpine
WORKDIR /srv
COPY server.py /srv/server.py
COPY site /srv/site
USER nobody
CMD ["python3", "/srv/server.py"]
