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

# s3cmd removed as not available for Debian 10 (buster)
# https://tracker.debian.org/pkg/s3cmd
#        s3cmd \
