FROM maven:3-amazoncorretto-8-alpine AS build
COPY . /tmp/
WORKDIR /tmp
RUN mvn clean package

FROM openjdk:8-alpine
RUN <<EOD
apk add bash nmap nmap-scripts openssh-client sshpass curl sudo
mkdir /app
chown -R daemon:daemon /app
EOD

COPY --from=build /tmp/target/*.jar /app/
COPY start.sh /app/
WORKDIR /app
CMD bash start.sh
