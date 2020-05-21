ARG BUILD_FROM
FROM $BUILD_FROM

#set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV LANG C.UTF-8

RUN apk update && apk add --no-cache bash sudo dhcp iptables net-tools util-linux

WORKDIR /data

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
