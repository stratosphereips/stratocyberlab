FROM python:3.12-slim
WORKDIR /srv
COPY service.py /srv/service.py
USER 10001:10001
EXPOSE 8080
CMD ["python3", "/srv/service.py"]
