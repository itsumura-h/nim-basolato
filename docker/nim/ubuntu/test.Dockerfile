# ARG NIM_VERSION="2.0.0"
# FROM nimlang/nim:${NIM_VERSION}-ubuntu-regular

# # prevent timezone dialogue
# ENV DEBIAN_FRONTEND=noninteractive

# RUN apt update
# RUN apt upgrade -y
# RUN apt install -y \
#         gcc \
#         g++ \
#         make \
#         xz-utils \
#         ca-certificates \
#         libpcre3-dev \
#         vim \
#         curl \
#         git \
#         sqlite3 \
#         libpq-dev \
#         libmariadb-dev \
#         libsass-dev
# # gcc, g++... for Nim
# # make... for NimLangServer
# # xz-utils... for unzip tar.xz
# # ca-certificates... for https
# # libpcre3-dev... for nim regex

# ENV PATH $PATH:/root/.nimble/bin
# WORKDIR /root/project
# COPY ./basolato.nimble .
# RUN nimble install -y -d
# RUN git config --global --add safe.directory /root/project



FROM ubuntu:24.04

# prevent timezone dialogue
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt upgrade -y
RUN apt install -y \
        gcc \
        xz-utils \
        ca-certificates \
        libpcre3-dev \
        vim \
        curl \
        git \
        libsass-dev

# gcc, g++... for Nim
# xz-utils... for unzip tar.xz
# ca-certificates... for https
# libpcre3-dev... for nim regex

ARG NIM_VERSION="2.0.0"
WORKDIR /root
RUN curl https://nim-lang.org/choosenim/init.sh -o init.sh
RUN sh init.sh -y
RUN rm -f init.sh
ENV PATH $PATH:/root/.nimble/bin
RUN choosenim ${NIM_VERSION}

WORKDIR /root/project
COPY ./basolato.nimble .
RUN nimble install -y -d

RUN git config --global --add safe.directory /root/project

WORKDIR /root/project
