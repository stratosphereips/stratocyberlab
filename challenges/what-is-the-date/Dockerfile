FROM python:3.11-slim-bullseye

EXPOSE 80

WORKDIR /opt/app/

RUN apt update && apt install -y netcat
RUN pip3 install flask

COPY server.py .
COPY index.html .

CMD ["python3", "server.py"]