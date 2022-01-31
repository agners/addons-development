FROM --platform=linux/amd64 debian:buster AS builder

ENV \
    LANG="C.UTF-8" \
    DEBIAN_FRONTEND="noninteractive" \
    CURL_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"

WORKDIR /usr/src

COPY debian-armhf.cmake /usr/src

RUN \
    set -x \
    && dpkg --add-architecture armhf \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       bash \
       curl \
       ca-certificates \
       build-essential \
       crossbuild-essential-armhf \
       git

FROM builder AS cpcd-builder

ARG CPCD_VERSION=alpha/4.0.1.0

RUN \
    set -x \
    && apt-get install -y --no-install-recommends \
       cmake \
       libmbedtls-dev:armhf \
       libmbedtls12:armhf \
    && git clone --depth 1 -b ${CPCD_VERSION} \
       https://github.com/SiliconLabs/cpc-daemon.git \
    && mkdir cpc-daemon/build && cd cpc-daemon/build \
    && cmake ../ \
       -DCMAKE_TOOLCHAIN_FILE=../debian-armhf.cmake \
    && make \
    && make install

FROM builder AS zigbeed-builder

ARG GECKO_SDK_VERSION=v4.0.1

RUN \
    set -x \
    && apt-get install -y --no-install-recommends \
       python3 \
       python3-jinja2 \
       python3-pip \
       openjdk-11-jre \
       git-lfs \
       unzip \
    && curl -O https://www.silabs.com/documents/login/software/slc_cli_linux.zip \
    && unzip slc_cli_linux.zip \
    && cd slc_cli/ && chmod +x slc
 
ENV PATH="/usr/src/slc_cli/:$PATH"

RUN \
    set -x \
    && git clone --depth 1 -b ${GECKO_SDK_VERSION} \
       https://github.com/SiliconLabs/gecko_sdk.git

# zigbeed links against libcpc.so
COPY --from=cpcd-builder /usr/local/ /usr/local/

RUN \
    set -x \
    && cd gecko_sdk/protocol/zigbee \
    && slc signature trust --sdk=../.. \
    && slc generate \
       --sdk=../.. \
       --with=linux_arch_32 -p=app/zigbeed/zigbeed.slcp \
       --export-destination=app/zigbeed/output \
    && cd app/zigbeed/output \
    && make -f zigbeed.Makefile \
        AR=arm-linux-gnueabihf-ar \
        CC=arm-linux-gnueabihf-gcc \
        LD=arm-linux-gnueabihf-gcc \
        CXX=arm-linux-gnueabihf-g++ \
        debug


FROM --platform=linux/arm/v7 arm32v7/debian:buster

# From github.com/home-assistant/docker-base, debian/Dockerfile
ARG S6_OVERLAY_VERSION=2.1.0.2
ARG TEMPIO_VERSION=2021.09.0
ARG BUILD_ARCH=armv7

ENV \
    LANG="C.UTF-8" \
    DEBIAN_FRONTEND="noninteractive" \
    CURL_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES=1

RUN \
    set -x \
    && apt-get update && apt-get install -y --no-install-recommends \
        bash \
        jq \
        tzdata \
        curl \
        ca-certificates \
    && mkdir -p /usr/share/man/man1 \
    \
    && if [ "${BUILD_ARCH}" = "armv7" ]; then \
            export S6_ARCH="arm"; \
        elif [ "${BUILD_ARCH}" = "i386" ]; then \
            export S6_ARCH="x86"; \
        else \
            export S6_ARCH="${BUILD_ARCH}"; \
        fi \
    \
    && curl -L -f -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.gz" \
        | tar zxvf - -C / \
    && mkdir -p /etc/fix-attrs.d \
    && mkdir -p /etc/services.d \
    && curl -L -f -s -o /usr/bin/tempio \
        "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${BUILD_ARCH}" \
    && chmod a+x /usr/bin/tempio

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" \
    CPCD_TRACE="false" \
    CPCD_DEVICE="/dev/ttyUSB0"

RUN \
    set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       libmbedtls12 \
       socat \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/src/*

COPY --from=cpcd-builder /usr/local/ /usr/local/
COPY --from=zigbeed-builder \
     /usr/src/gecko_sdk/protocol/zigbee/app/zigbeed/output/build/debug/zigbeed \
     /usr/local/bin
COPY --from=zigbeed-builder \
     /usr/src/gecko_sdk/app/host/multiprotocol/zigbeed/multiprotocol-container/_artifacts/etc/zigbeed.conf \
     /usr/local/etc

RUN touch /accept_silabs_msla

COPY rootfs /

# use s6-overlay as init system
WORKDIR /
ENTRYPOINT ["/init"]
