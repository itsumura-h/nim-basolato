ARG IMAGE_TAG="1.4.4-alpine"
FROM nimlang/nim:${IMAGE_TAG}

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
        openssh-client \
        openssl \
        pcre \
        bsd-compat-headers \
        lcov \
        sqlite mariadb-dev libpq && \
    rm /usr/lib/mysqld* -fr && rm /usr/bin/mysql* -fr
WORKDIR /root/project/
ADD ./basolato.nimble /root/project/
ENV PATH $PATH:/root/.nimble/bin
