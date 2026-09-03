# syntax=docker/dockerfile:1
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

COPY --from=ghcr.io/astral-sh/uv:0.12.9@sha256:8b940d3a9d65bed080436972241af2e21c84b5e8c9193f7014ed71479ee795ff /uv /bin/uv

COPY dashboard/server/requirements.txt .
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=0
RUN --mount=type=cache,target=/root/.cache/uv \
    uv venv --python /usr/local/bin/python /opt/venv \
    && uv pip install --python /opt/venv/bin/python -r requirements.txt

# Final stage
FROM python:3.12-slim

# Install Docker client
RUN apt-get update \
 && apt-get install -y docker.io docker-compose curl \
 && rm -rf /var/lib/apt/lists/*


ARG APP=/var/opt/app/
WORKDIR $APP

# Copy Python dependencies
COPY --from=download-python /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy built Svelte files
COPY --from=build-svelte /app/public $APP/public

COPY dashboard/server/*.py $APP/

# exec is important to receive sigterm and perform graceful shutdown when container is being terminated
CMD ["bash", "-c", "python ws_ssh.py & exec python -m hypercorn app:app --bind 0.0.0.0:80 --keep-alive 120 --graceful-timeout 120 --access-log - --error-log -"]
