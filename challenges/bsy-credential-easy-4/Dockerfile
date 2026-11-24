FROM python:3.12-slim
WORKDIR /srv
COPY snmp_service.py /srv/snmp_service.py
COPY snmp_healthcheck.py /srv/snmp_healthcheck.py
COPY protected-record.txt /srv/protected-record.txt
CMD ["python3", "/srv/snmp_service.py"]
