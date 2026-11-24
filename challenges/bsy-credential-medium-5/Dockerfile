FROM postgres:16-alpine
COPY pg_hba.conf /etc/postgresql/pg_hba.conf
COPY init.sql /docker-entrypoint-initdb.d/10-paste-archive.sql
