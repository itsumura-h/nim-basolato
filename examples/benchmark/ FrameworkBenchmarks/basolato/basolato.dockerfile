FROM nimlang/nim:alpine

ENV PATH $PATH:/root/.nimble/bin

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
        openssh-client \
        ca-certificates \
        openssl \
        pcre \
        bsd-compat-headers \
        lcov \
        sqlite mariadb-dev libpq && \
    rm /usr/lib/mysqld* -fr && rm /usr/bin/mysql* -fr && \
    update-ca-certificates

ADD ./ /root/project
WORKDIR /root/project

RUN nimble install -y https://github.com/itsumura-h/nim-basolato@#test-db_timeout && \
    nimble remove -y allographer && \
    nimble install allographer@#head
ENV DB_MAX_CONNECTION=500
RUN ducere build -p:8080

EXPOSE 8080

CMD ./main
