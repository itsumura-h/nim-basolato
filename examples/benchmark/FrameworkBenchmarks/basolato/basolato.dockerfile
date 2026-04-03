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
    curl \
    git \
    # for postgres
    libpq-dev

ARG VERSION="2.2.8"
WORKDIR /root
RUN curl https://nim-lang.org/choosenim/init.sh -o init.sh
RUN sh init.sh -y
RUN rm -f init.sh
ENV PATH $PATH:/root/.nimble/bin
RUN choosenim ${VERSION}

ENV PATH $PATH:/root/.nimble/bin

ADD ./ /basolato
WORKDIR /basolato

# Install dependencies only; avoid building this benchmark package via nimble.
RUN nimble install -y -d
RUN ducere build -a --httpbeast

RUN chmod +x main
RUN chmod +x startServer.sh

ENV SECRET_KEY="secret_key"

EXPOSE 8080

CMD ./startServer.sh
