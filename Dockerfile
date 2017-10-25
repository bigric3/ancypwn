FROM ubuntu:xenial

MAINTAINER Anciety <ding641880047@126.com>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -qy \
    git nasm  python \
    build-essential \
    python-dev python-pip python-setuptools \
    libc6-dbg \
    gcc-multilib \
    gdb \
    gcc \
    wget \
    curl \
    glibc-source \
    cmake \
    python-capstone && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd ~ && git clone https://github.com/keystone-engine/keystone.git && \
    cd keystone && \
    mkdir build && cd ~/keystone/build && ../make-share.sh && \
    make install && \
    cd /tmp && \
    echo "/usr/local/lib" >> /etc/ld.so.conf && \
    ldconfig && rm -rf ~/keystone && \
    pip install keystone-engine && \
    rm -rf ~/keystone

# the apt-get on top is too huge, seperate a little
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -qy \
    socat \
    netcat && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*  && \
    cd ~ && \
    tar -xvf /usr/src/glibc/glibc-2.23.tar.xz

ARG BUILD_VER=unknown

# pip, pwntools, ropper
# These things may update
#    wget -O ~/.gdbinit-gef.py -q https://github.com/hugsy/gef/raw/master/gef.py && \
# experimental gef version of myself
RUN BUILD_VER=${BUILD_VER} pip install -U pip && \
    pip install pwntools ropper ancypatch && \
    pip install git+https://github.com/Escapingbug/roputils.git && \
    wget -O ~/.gdbinit-gef.py -q https://raw.githubusercontent.com/Escapingbug/gef/master/gef.py &&
    echo source ~/.gdbinit-gef.py >> ~/.gdbinit

# Set the locale, so that we can use unicode and send signal in gef
ENV LANG C.UTF-8

VOLUME ["/pwn"]
WORKDIR /pwn

# I personally prefer to use root user, I think that's fine for this.
CMD ["/bin/bash"]
