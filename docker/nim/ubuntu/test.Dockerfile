FROM ubuntu:24.04

# prevent timezone dialogue
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt upgrade -y
RUN apt install -y \
      # for build Nim
      build-essential \
      # for unzip tar.xz
      xz-utils \
      # for https
      ca-certificates \
      # for nim regex
      libpcre3-dev \
      vim \
      curl \
      git 

ARG NIM_VERSION="2.0.0"
WORKDIR /root
RUN curl https://nim-lang.org/choosenim/init.sh -o init.sh
RUN sh init.sh -y
RUN rm -f init.sh
ENV PATH $PATH:/root/.nimble/bin
RUN choosenim ${NIM_VERSION}

WORKDIR /application
COPY ./basolato.nimble .
RUN nimble install -y -d

RUN git config --global --add safe.directory /application

WORKDIR /application
