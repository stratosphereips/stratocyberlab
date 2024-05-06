FROM python:3-slim

ARG APP=/opt/app/
WORKDIR $APP

# Create bob user with home and add a flag to his home
RUN useradd -m -s "/bin/bash" "bob" 
COPY data/flag.txt /home/bob/flag
COPY data/flag.txt /home/bob/flag.txt

RUN mkdir -p $APP
COPY server.py $APP/
COPY data/quotes/ /

CMD ["python3", "server.py"]
