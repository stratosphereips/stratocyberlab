FROM python:3.12-slim
WORKDIR /app
RUN pip install --no-cache-dir pyftpdlib==2.0.1
COPY server.py /app/server.py
CMD ["python", "/app/server.py"]
