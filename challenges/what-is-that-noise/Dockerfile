FROM python:3-slim

ARG APP=/opt/app/
WORKDIR $APP

RUN pip install scapy
COPY meta.json /meta.json
RUN cat /meta.json | egrep -o 'BSY{.*}' > /tmp/flag.txt && rm /meta.json

RUN mkdir -p $APP
COPY server.py $APP/

CMD ["python3", "server.py"]
