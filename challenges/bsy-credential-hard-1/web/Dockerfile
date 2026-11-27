FROM python:3.12-slim
WORKDIR /app
COPY server.py /app/server.py
COPY flag.txt /app/flag.txt
USER nobody
CMD ["python3", "/app/server.py"]
