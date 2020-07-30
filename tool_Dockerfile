FROM ubuntu:20.04

WORKDIR /
RUN apt-get update -yqq && \
    apt-get install -y wget curl
RUN wget https://raw.githubusercontent.com/ekalinin/github-markdown-toc/master/gh-md-toc
RUN chmod +x gh-md-toc
WORKDIR /work
ENTRYPOINT ["/gh-md-toc"]
