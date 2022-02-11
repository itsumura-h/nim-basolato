FROM nimlang/nim:1.6.2-ubuntu-regular

RUN apt update; apt install -y libgnutls30 && \
    apt update && \
    apt upgrade -y && \
    apt install -y --no-install-recommends \
        vim \
        curl \
        sqlite \
        libpq-dev \
        libmysqlclient-dev \
        libsass-dev
ENV PATH $PATH:/root/.nimble/bin
WORKDIR /root/project

