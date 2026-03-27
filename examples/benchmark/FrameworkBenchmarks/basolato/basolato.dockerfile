FROM ubuntu:24.04 AS build

# prevent timezone dialogue
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt upgrade -y
RUN apt install -y \
        build-essential \
        xz-utils \
        ca-certificates \
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

RUN nimble install -y
RUN ducere build -a


FROM ubuntu:24.04 AS runtime

# prevent timezone dialogue
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt upgrade -y
RUN apt install -y \
        xz-utils \
        ca-certificates \
        libpq-dev

WORKDIR /basolato
COPY --from=build /basolato/main .
RUN chmod +x main
COPY --from=build /basolato/startServer.sh .
RUN chmod +x startServer.sh

# Secret
ENV SECRET_KEY="secret_key"
# DB Connection
ENV DB_URL="postgresql://benchmarkdbuser:benchmarkdbpass@tfb-database:5432/hello_world"
ENV DB_MAX_CONNECTION=2000
ENV DB_TIMEOUT=30


EXPOSE 8080

CMD ./startServer.sh
