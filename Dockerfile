ARG debVersion=10
FROM debian:${debVersion}
MAINTAINER Peter Mount <peter@retep.org>

RUN mkdir -p /var/run/sshd /opt &&\
    apt-get update &&\
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
	man \
        curl \
        libcurl4-openssl-dev \
        s3cmd \
        unzip \
        vim \
        zip \
        aufs-tools \
        autoconf \
        automake \
        build-essential \
        cvs \
        git \
        mercurial \
        reprepro \
        subversion \
        make \
        gcc \
        g++ \
        python \
        paxctl
