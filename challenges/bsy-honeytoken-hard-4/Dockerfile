FROM redis:7-alpine
COPY start.sh /opt/start.sh
COPY users.acl /opt/users.acl
COPY ledger.txt /opt/ledger.txt
RUN chmod 755 /opt/start.sh
CMD ["/bin/sh", "/opt/start.sh"]
