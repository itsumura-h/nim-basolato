FROM ubuntu:22.04

# prevent timezone dialogue
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt upgrade -y
RUN apt install -y --fix-missing \
        gcc \
        g++ \
        xz-utils \
        ca-certificates \
        vim \
        wget \
        git \
        sqlite3 \
        libpq-dev \
        libmariadb-dev \
        libsass-dev

ARG VERSION="1.6.10"
WORKDIR /root
RUN wget --inet4-only https://nim-lang.org/download/nim-${VERSION}-linux_x64.tar.xz && \
    tar -Jxf nim-${VERSION}-linux_x64.tar.xz && \
    rm -f nim-${VERSION}-linux_x64.tar.xz && \
    mv nim-${VERSION} .nimble

ENV PATH $PATH:/root/.nimble/bin
WORKDIR /root/project

