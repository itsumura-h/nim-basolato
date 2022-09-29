FROM centos:centos8.4.2105

RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-*;
RUN dnf update -y && \
    dnf makecache
RUN dnf install -y --enablerepo=powertools \
      gcc \
      vim \
      wget \
      git \
      libsass-devel

ARG VERSION="1.6.8"
WORKDIR /root
RUN wget --inet4-only https://nim-lang.org/download/nim-${VERSION}-linux_x64.tar.xz && \
    tar -Jxf nim-${VERSION}-linux_x64.tar.xz && \
    rm -f nim-${VERSION}-linux_x64.tar.xz && \
    mv nim-${VERSION}/* .nimble/

ENV PATH $PATH:/root/.nimble/bin
WORKDIR /root/project
