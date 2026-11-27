FROM python:3.12-slim
WORKDIR /app
RUN pip install --no-cache-dir Flask==3.1.0
COPY app.py /app/app.py
USER 10001:10001
CMD ["python", "/app/app.py"]
