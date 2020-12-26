ARG BUILD_FROM
FROM $BUILD_FROM

MAINTAINER Alvaro Ramos <alvaro.ramos.soltero@gmail.com>

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV LANG C.UTF-8

# Install requirements for add-on
RUN  apk update && apk add --no-cache bash fping && rm -rf /var/cache/apk/*

COPY netscan /usr/sbin
RUN chmod a+x /usr/sbin/netscan

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]