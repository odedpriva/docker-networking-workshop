FROM alpine
RUN apk add --no-cache \
    curl \
    tcpdump \
    iptables \
    drill \
    iproute2
RUN apk add --update netcat-openbsd && rm -rf /var/cache/apk/*
EXPOSE 8000