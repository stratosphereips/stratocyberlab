FROM python:3.12-slim
RUN pip install --no-cache-dir pyftpdlib
WORKDIR /srv
COPY server.py /srv/server.py
COPY shift-note.txt /srv/ftp/shift-note.txt
CMD ["python3", "/srv/server.py"]
