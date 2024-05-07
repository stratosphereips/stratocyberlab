FROM python:3-slim

ARG APP=/var/opt/app/
WORKDIR $APP

RUN pip3 install Flask

RUN mkdir -p $APP
COPY app.py $APP/
COPY templates $APP/templates
COPY static $APP/static

CMD ["python3", "app.py"]
