FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends dovecot-imapd python3 && rm -rf /var/lib/apt/lists/*
COPY dovecot.conf /etc/dovecot/dovecot.conf
COPY users /etc/dovecot/users
COPY mail/ /var/mail/ensign/Maildir/
RUN groupadd --gid 10001 mailuser && \
    useradd --system --uid 10001 --gid 10001 --no-create-home --shell /usr/sbin/nologin mailuser && \
    chown -R mailuser:mailuser /var/mail/ensign && \
    chmod 644 /etc/dovecot/users
EXPOSE 143
CMD ["dovecot", "-F"]
