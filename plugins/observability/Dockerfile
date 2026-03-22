FROM python:3.12-alpine

RUN apk add --no-cache docker-cli

WORKDIR /app

COPY app.py /app/app.py

EXPOSE 9001

CMD ["python", "/app/app.py"]
