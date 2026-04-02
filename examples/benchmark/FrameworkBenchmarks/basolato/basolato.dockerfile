FROM ubuntu:24.04 AS build

# prevent timezone dialogue
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt upgrade -y
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
    git

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


FROM ubuntu:24.04 AS runtime

# prevent timezone dialogue
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt upgrade -y
RUN apt install -y \
    # for build Nim
    build-essential \
    # for https
    ca-certificates \
    # for nim regex
    libpcre3-dev \
    # for postgres
    libpq-dev

WORKDIR /basolato
COPY --from=build /basolato/main .
RUN chmod +x main
COPY --from=build /basolato/startServer.sh .
RUN chmod +x startServer.sh

ENV SECRET_KEY="secret_key"
ENV DB_URL="postgresql://benchmarkdbuser:benchmarkdbpass@tfb-database:5432/hello_world"

EXPOSE 8080

CMD ./startServer.sh
