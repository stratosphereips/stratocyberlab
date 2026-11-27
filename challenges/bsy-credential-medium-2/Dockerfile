FROM python:3.12-slim
WORKDIR /srv
COPY service.py /srv/service.py
COPY public /srv/public
COPY crew-record.txt /srv/crew-record.txt
CMD ["python3", "/srv/service.py"]
