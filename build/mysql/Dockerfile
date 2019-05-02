FROM mariadb:latest
MAINTAINER ChurchCRM

RUN apt-get update \
    && apt-get install -y jq \
    && mkdir -p /scripts/pre-init.d/

COPY ./entrypoint.sh /scripts/entrypoint.sh
RUN chmod +x /scripts/entrypoint.sh
ENV TERM="xterm-color"

ENTRYPOINT ["/scripts/entrypoint.sh"]
