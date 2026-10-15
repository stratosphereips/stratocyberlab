FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends ssh sshpass \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY ssh-attack.sh /ssh-attack.sh

CMD ["/ssh-attack.sh"]