FROM alpine
RUN apk add --no-cache \
    curl \
    tcpdump \
    iptables \
    drill \
    iproute2
RUN curl -L https://github.com/sequenceiq/docker-alpine-dig/releases/download/v9.10.2/dig.tgz|tar -xzv -C /usr/local/bin/
RUN apk add --update netcat-openbsd && rm -rf /var/cache/apk/*
EXPOSE 8000