FROM ubuntu:21.10

# prevent timezone dialogue
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update --fix-missing && \
    apt upgrade -y
RUN apt install -y --fix-missing \
        gcc \
        xz-utils \
        pcre-dev \
        ca-certificates \
        vim \
        wget \
        git \
        libpq-dev

ARG VERSION="1.6.6"
WORKDIR /root
RUN wget https://nim-lang.org/download/nim-${VERSION}-linux_x64.tar.xz && \
    tar -Jxf nim-${VERSION}-linux_x64.tar.xz && \
    rm -f nim-${VERSION}-linux_x64.tar.xz && \
    mv nim-${VERSION} .nimble

ENV PATH $PATH:/root/.nimble/bin

ADD ./ /basolato
WORKDIR /basolato

RUN nimble install -y
RUN ducere build -p:8080

EXPOSE 8080

CMD ./main
