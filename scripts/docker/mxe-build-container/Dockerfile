From ubuntu:20.04

SHELL ["/bin/bash", "-c"]

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
ENV PATH "$PATH:/usr/lib/mxe/usr/bin/"

# Update and add needed packages for MXE.
RUN apt-get update && apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    autoconf \
    automake \
    autopoint \
    bash \
    binutils \
    dirmngr \
    git \
    gpg \
    gpg-agent \
    lsb-release \
    make \
    software-properties-common \
    zip

# Add GPG keys for MXE APT.
RUN apt-key adv \
    --keyserver keyserver.ubuntu.com \
    --recv-keys 86B72ED9 && \
    add-apt-repository \
    "deb [arch=amd64] https://pkg.mxe.cc/repos/apt `lsb_release -sc` main"

# Install MXE packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install --no-install-recommends -y \
    mxe-{i686,x86-64}-w64-mingw32.shared-{gcc,openssl,qtbase,nsis,curl,libzip,libgit2,qtconnectivity,qtcharts,qtdeclarative,qtimageformats,qtquickcontrols,qtquickcontrols2,qtgraphicaleffects,qttools,qttranslations,zstd}