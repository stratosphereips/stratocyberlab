FROM python:3-slim

ARG APP=/opt/app/
WORKDIR $APP

# Create bob user with home and add a flag to his home
RUN pip install scapy
COPY meta.json /meta.json
RUN cat /meta.json | egrep -o 'bsy{.*}' > /tmp/flag.txt && \
    rm /meta.json

RUN mkdir -p $APP
COPY server.py $APP/

CMD ["python3", "server.py"]
