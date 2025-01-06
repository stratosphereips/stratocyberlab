FROM postgres:9-alpine
ENV POSTGRES_DB="dashboard"
ENV POSTGRES_PASSWORD="xuZdS}3bp7OjAx8^tQXbm`z^O1h#~G2Fb`Df#@BMo5E5IA4WxC`nj`M9O5ZE"
RUN mkdir -p /docker-entrypoint-initdb.d
COPY 001-init-db.sql /docker-entrypoint-initdb.d/
