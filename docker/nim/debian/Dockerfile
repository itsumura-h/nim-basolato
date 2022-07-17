FROM debian:11.2-slim

RUN apt update --fix-missing && \
    apt upgrade -y
RUN apt install -y  --fix-missing \
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

ARG IMAGETAG="1.6.6"
WORKDIR /root
RUN wget https://nim-lang.org/download/nim-${IMAGETAG}-linux_x64.tar.xz && \
    tar -Jxf nim-${IMAGETAG}-linux_x64.tar.xz && \
    rm -f nim-${IMAGETAG}-linux_x64.tar.xz && \
    mv nim-${IMAGETAG} .nimble

ENV PATH $PATH:/root/.nimble/bin
WORKDIR /root/project
