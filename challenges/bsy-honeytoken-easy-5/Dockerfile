FROM python:3.12-alpine
WORKDIR /app
COPY service.py /app/service.py
RUN adduser -D -H -u 10001 service
USER service
CMD ["python3", "/app/service.py"]
