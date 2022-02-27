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

WORKDIR /root
RUN wget https://nim-lang.org/download/nim-1.6.2-linux_x64.tar.xz && \
    tar -Jxf nim-1.6.2-linux_x64.tar.xz && \
    rm -f nim-1.6.2-linux_x64.tar.xz && \
    mkdir /root/.nimble && \
    mv nim-1.6.2/* .nimble/

ENV PATH $PATH:/root/.nimble/bin
WORKDIR /root/project
