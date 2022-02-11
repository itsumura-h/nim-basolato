FROM debian:11.2-slim

RUN apt update && \
    apt upgrade -y
RUN apt install -y --no-install-recommends \
        gcc \
        xz-utils \
        ca-certificates \
        vim \
        wget \
        git \
        sqlite3 \
        libpq-dev \
        libmariadb-dev \
        libsass-dev

WORKDIR /root
RUN wget https://nim-lang.org/download/nim-1.6.2-linux_x64.tar.xz && \
    tar -Jxf nim-1.6.2-linux_x64.tar.xz && \
    rm nim-1.6.2-linux_x64.tar.xz && \
    mv nim-1.6.2 .nimble

ENV PATH $PATH:/root/.nimble/bin
WORKDIR /root/project
