FROM python:3-slim

RUN apt update && apt install -y gcc

RUN mkdir /opt/app
WORKDIR /opt/app

COPY main.c send.py /opt/app/

RUN gcc main.c -o binary && gzip binary

CMD ["python3", "send.py"]
