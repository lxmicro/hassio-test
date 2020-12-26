ARG BUILD_FROM
FROM $BUILD_FROM

MAINTAINER Alvaro Ramos <alvaro.ramos.soltero@gmail.com>

# Set shell
SHELL ["/bin/bash", "-c"]

ENV LANG C.UTF-8

# Install requirements for add-on
RUN  apk update && apk add --no-cache bash fping mosquitto-clients && rm -rf /var/cache/apk/*

WORKDIR /data
COPY netscan netscan
RUN chmod a+x netscan

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]