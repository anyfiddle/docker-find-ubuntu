FROM ubuntu

# udev is needed for booting a "real" VM, setting up the ttyS0 console properly
# kmod is needed for modprobing modules
# systemd is needed for running as PID 1 as /sbin/init
# Also, other utilities are installed
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections

RUN apt-get update && apt-get install -y \
    curl \
    cloud-init \
    build-essential \
    dbus \
    git \
    htop \
    kmod \
    iproute2 \
    iputils-ping \
    less \
    locales \
    nano \
    net-tools \
    netplan.io \
    openssh-server \
    openssl \
    resolvconf \
    rng-tools \
    software-properties-common \
    sudo \
    systemd \
    udev \
    unzip \
    vim \
    wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create the following files, but unset them
RUN echo "" > /etc/machine-id && echo "" > /var/lib/dbus/machine-id

# This container image doesn't have locales installed. Disable forwarding the
# user locale env variables or we get warnings such as:
#  bash: warning: setlocale: LC_ALL: cannot change locale
RUN sed -i -e 's/^AcceptEnv LANG LC_\*$/#AcceptEnv LANG LC_*/' /etc/ssh/sshd_config

RUN adduser --gecos '' --disabled-password ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd && \
    chsh -s /bin/bash ubuntu

# Set the root password to root when logging in through the VM's ttyS0 console
RUN echo "root:root" | chpasswd

COPY ./.bashrc /home/ubuntu/.bashrc

COPY ./netplan-config.yaml /etc/netplan/config.yaml
COPY ./prepare.sh /prepare.sh

RUN runnerVersion=$(curl https://anyfiddle-runner-releases.s3-us-west-2.amazonaws.com/latest-version-master.txt) && \
    wget https://anyfiddle-runner-releases.s3-us-west-2.amazonaws.com/anyfiddle-${runnerVersion}.tar.gz -O anyfiddle-runner.tar.gz && \
    mkdir -p /var/runner/anyfiddle && \
    tar -xf anyfiddle-runner.tar.gz -C /var/runner/anyfiddle && \
    rm anyfiddle-runner.tar.gz

COPY anyfiddle-runner.service /etc/systemd/system/anyfiddle-runner.service
