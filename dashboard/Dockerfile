# Stage 1: Build Svelte Application
FROM node:22-alpine AS build-svelte
WORKDIR /app

COPY dashboard/client/ ./

RUN npm install
RUN npm run build

# parse current commit hash without the git tool
COPY .git/HEAD ./.git/HEAD
COPY .git/refs/heads ./.git/refs/heads
RUN headref=$(awk '{ print $2 }' .git/HEAD) \
    && cp ".git/$headref" public/current-commit.txt

# Stage 2: Download Python dependencies
FROM python:3.12-slim AS download-python

COPY dashboard/server/requirements.txt .
RUN pip install -r requirements.txt --user

# Final stage
FROM python:3.12-slim

# Install Docker client
RUN apt-get update \
 && apt-get install -y docker.io docker-compose curl \
 && rm -rf /var/lib/apt/lists/*


ARG APP=/var/opt/app/
WORKDIR $APP

# Copy Python dependencies
COPY --from=download-python /root/.local/lib/python3.12/site-packages /root/.local/lib/python3.12/site-packages

# Copy built Svelte files
COPY --from=build-svelte /app/public $APP/public

COPY dashboard/server/*.py $APP/

# exec is important to receive sigterm and perform graceful shutdown when container is being terminated
CMD ["bash", "-c", "python ws_ssh.py & exec python -m hypercorn app:app --bind 0.0.0.0:80 --keep-alive 120 --graceful-timeout 120 --access-log - --error-log -"]
