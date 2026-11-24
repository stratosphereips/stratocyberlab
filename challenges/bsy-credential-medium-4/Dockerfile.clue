FROM python:3.12-alpine
WORKDIR /srv
COPY clue_service.py /srv/clue_service.py
CMD ["python3", "/srv/clue_service.py"]
