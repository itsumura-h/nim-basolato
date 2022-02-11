FROM nimlang/nim:1.6.2-alpine-regular

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
        openssh-client \
        openssl \
        pcre \
        bsd-compat-headers \
        lcov \
        sqlite \
        mariadb-dev \
        libpq \
        libsass-dev && \
    rm /usr/lib/mysqld* -fr && rm /usr/bin/mysql* -fr
ENV PATH $PATH:/root/.nimble/bin
WORKDIR /root/project/
