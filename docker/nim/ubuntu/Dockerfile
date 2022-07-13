ARG IMAGE_TAG="1.6.6-ubuntu-regular"
FROM nimlang/nim:${IMAGE_TAG}

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

