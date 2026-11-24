FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends vsftpd python3 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --no-create-home --home-dir /srv/actuator --shell /bin/bash mech_maint \
    && echo 'mech_maint:servo-echo-27' | chpasswd \
    && mkdir -p /srv/actuator /var/run/vsftpd/empty \
    && chown root:root /srv/actuator \
    && chmod 755 /srv/actuator

COPY vsftpd.conf /etc/vsftpd.conf
COPY flag.txt /srv/actuator/recovery-record.txt
RUN chown root:root /srv/actuator/recovery-record.txt && chmod 444 /srv/actuator/recovery-record.txt

EXPOSE 21
CMD ["/usr/sbin/vsftpd", "/etc/vsftpd.conf"]
