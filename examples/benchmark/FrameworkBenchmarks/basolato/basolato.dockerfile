FROM ubuntu:22.04 AS build

# prevent timezone dialogue
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt upgrade -y
RUN apt install -y --fix-missing \
        gcc \
        xz-utils \
        ca-certificates \
        curl \
        git

ARG VERSION="2.0.2"
WORKDIR /root
RUN curl https://nim-lang.org/choosenim/init.sh -o init.sh
RUN sh init.sh -y
RUN rm -f init.sh
ENV PATH $PATH:/root/.nimble/bin
RUN choosenim ${VERSION}

ENV PATH $PATH:/root/.nimble/bin

ADD ./ /basolato
WORKDIR /basolato

RUN nimble install -y
RUN ducere build -p:8080 -o:speed


FROM ubuntu:22.04 AS runtime

# prevent timezone dialogue
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt upgrade -y
RUN apt install -y --fix-missing \
        xz-utils \
        ca-certificates \
        libpq-dev

WORKDIR /basolato
COPY --from=build /basolato/main .
RUN chmod 111 main
COPY --from=build /basolato/startServer.sh .
RUN chmod 111 startServer.sh


# Secret
ENV SECRET_KEY="pZWEVzA7h2FcKLgVM3ec5Eiik7eU9Ehpf0uLdYOZDgr0uZKIo5LdQE9sjIub3IDkUTrf3X2Jsh1Uw8b02GtAfWRn4C9NptfdSyoK"
# Logging
ENV LOG_IS_DISPLAY=false
ENV LOG_IS_FILE=false
ENV LOG_IS_ERROR_FILE=false
# Session db
# Session type, file or redis, is defined in config.nims
ENV SESSION_TIME=120
ENV LOCALE=en


EXPOSE 8080

CMD ./startServer.sh
