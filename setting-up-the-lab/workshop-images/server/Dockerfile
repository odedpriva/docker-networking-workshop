FROM node:6.9.4-alpine
RUN apk add --no-cache \
    curl \
    tcpdump \
    iptables \
    drill \
    iproute2
RUN curl -L https://github.com/sequenceiq/docker-alpine-dig/releases/download/v9.10.2/dig.tgz|tar -xzv -C /usr/local/bin/
RUN apk add --update netcat-openbsd && rm -rf /var/cache/apk/*
WORKDIR /usr/src/app
RUN mkdir -p /usr/src/app
COPY package.json /usr/src/app/
RUN npm install
COPY . /usr/src/app
CMD ["npm","start"]