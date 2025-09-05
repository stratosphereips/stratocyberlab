FROM python:slim

RUN mkdir -p /opt/app
WORKDIR /opt/app

COPY requirements.txt /opt/app/requirements.txt
RUN pip install -r /opt/app/requirements.txt

COPY secret.txt /opt/secret.txt

COPY main.py /opt/app/main.py

EXPOSE 80
CMD ["python", "/opt/app/main.py"]