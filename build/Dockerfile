FROM debian:stable
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y wget python-gobject lftp curl gpg2; \
    apt-get clean; \
    wget https://downloads.sourceforge.net/project/zero-install/0install/2.12.1/0install-linux-x86_64-2.12.1.tar.bz2; \
    tar xf 0install-linux-x86_64-2.12.1.tar.bz2; \
    cd 0install-linux-x86_64-2.12.1; \
    ./install.sh local
