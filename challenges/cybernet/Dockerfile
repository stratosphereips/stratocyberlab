FROM python:3-slim

ARG APP=/opt/app/
WORKDIR $APP

RUN mkdir -p $APP
COPY server.py $APP/

CMD ["python3", "server.py"]
