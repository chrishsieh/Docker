FROM mariadb:latest
MAINTAINER ChurchCRM

RUN apt-get update && \
    apt-get install -y jq figlet
COPY ./startup /scripts/startup
RUN chmod +x /scripts/startup
ENTRYPOINT ["/scripts/startup"]
