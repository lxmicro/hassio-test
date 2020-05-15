ARG BUILD_FROM
FROM $BUILD_FROM

MAINTAINER Alvaro Ramos <alvaro.ramos.soltero@gmail.com>

#set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV LANG C.UTF-8

RUN apk update && apk add --no-cache bash sudo python3 python3-dev && rm -rf /var/cache/apk/*

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
