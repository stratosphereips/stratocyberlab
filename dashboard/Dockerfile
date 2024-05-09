# Stage 1: Build Svelte Application
FROM node:22-alpine AS build-svelte
WORKDIR /app

COPY client/ ./

RUN npm install
RUN npm run build

# Stage 2: Download Python dependencies
FROM cgr.dev/chainguard/python:latest-dev as download-python

COPY server/requirements.txt .
RUN pip install -r requirements.txt --user

# Final stage
FROM cgr.dev/chainguard/python:latest

ARG APP=/var/opt/app/
WORKDIR $APP

# Copy Python dependencies
COPY --from=download-python /home/nonroot/.local/lib/python3.12/site-packages /home/nonroot/.local/lib/python3.12/site-packages

# Copy built Svelte files
COPY --from=build-svelte /app/public $APP/public

COPY server/db.py $APP/
COPY server/app.py $APP/

ENTRYPOINT ["python", "app.py"]
