FROM redis:7-alpine
RUN apk add --no-cache python3
WORKDIR /challenge
COPY entrypoint.sh /challenge/entrypoint.sh
COPY decoys.py /challenge/decoys.py
RUN chmod 755 /challenge/entrypoint.sh
ENTRYPOINT ["/challenge/entrypoint.sh"]
