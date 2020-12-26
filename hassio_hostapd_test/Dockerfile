ARG BUILD_FROM
FROM $BUILD_FROM

MAINTAINER Alvaro Ramos <alvaro.ramos.soltero@gmail.com>

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV LANG C.UTF-8

# Install requirements for add-on
RUN  apk update && apk add --no-cache bash fping mosquitto-clients && rm -rf /var/cache/apk/*

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]