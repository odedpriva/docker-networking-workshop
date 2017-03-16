FROM node:6.9.4-alpine
RUN apk add --no-cache \
    curl \
    tcpdump \
    iptables \
    drill \
    iproute2 \
    ebtables \
    ethtool \
    tshark
RUN curl -L https://github.com/sequenceiq/docker-alpine-dig/releases/download/v9.10.2/dig.tgz|tar -xzv -C /usr/local/bin/
COPY nsenter /bin/nsenter
RUN chmod +x /bin/nsenter
RUN apk add --update netcat-openbsd && rm -rf /var/cache/apk/*