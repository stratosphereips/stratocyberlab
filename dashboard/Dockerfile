# Stage 1: Build Svelte Application
FROM node:22-alpine AS build-svelte
WORKDIR /app

COPY client/ ./

RUN npm install
RUN npm run build

# Stage 2: Download Python dependencies
FROM python:3-slim as download-python

COPY server/requirements.txt .
RUN pip install -r requirements.txt --user

# Final stage
FROM python:3-slim

# Install Docker client
RUN apt-get update && apt-get install -y docker.io docker-compose

ARG APP=/var/opt/app/
WORKDIR $APP

# Copy Python dependencies
COPY --from=download-python /root/.local/lib/python3.12/site-packages /root/.local/lib/python3.12/site-packages

# Copy built Svelte files
COPY --from=build-svelte /app/public $APP/public

COPY server/docker.py server/db.py server/app.py server/ws_ssh.py server/llm.py $APP/

# exec is important to receive sigterm and perform graceful shutdown when container is being terminated
CMD ["bash", "-c", "python ws_ssh.py & exec python app.py"]
