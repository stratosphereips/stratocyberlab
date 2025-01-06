FROM maven:3-amazoncorretto-8-alpine AS build
COPY . /tmp/
WORKDIR /tmp
RUN mvn clean package

FROM openjdk:8-alpine
RUN apk add bash nmap nmap-scripts openssh-client sshpass curl && mkdir /app && chown -R daemon:daemon /app
COPY --from=build /tmp/target/*.jar /app/
WORKDIR /app
USER daemon
CMD java -jar *.jar
