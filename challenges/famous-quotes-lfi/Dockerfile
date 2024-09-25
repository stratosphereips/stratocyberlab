FROM python:3-slim

ARG APP=/opt/app/
WORKDIR $APP

# Create bob user with home and add a flag to his home
RUN useradd -m -s "/bin/bash" "bob" 
COPY meta.json /meta.json
RUN cat /meta.json | egrep -o 'BSY{.*}' > /home/bob/flag.txt && \
    cp /home/bob/flag.txt /home/bob/flag && \
    rm /meta.json

RUN mkdir -p $APP
COPY server.py $APP/
COPY data/quotes/ /

CMD ["python3", "server.py"]
