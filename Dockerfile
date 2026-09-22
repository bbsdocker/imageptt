## Global docker arguments
ARG MY_DEBIAN_VERSION=trixie

FROM docker.io/library/debian:${MY_DEBIAN_VERSION} AS pttbbs-builder-base

COPY confs /tmp/confs
## if some bugs in new distro version, workaround here may be enabled:
COPY patches /tmp/patches
COPY build_ptt.sh /tmp/build_ptt.sh

ARG MY_DEBIAN_VERSION
ARG MY_DEBIAN_VERSION_NUMBER
ARG USE_TWDS_MIRROR
ENV DEBIAN_VERSION=${MY_DEBIAN_VERSION}
ENV DEBIAN_VERSION_NUMBER=${MY_DEBIAN_VERSION_NUMBER}
ENV DEBIAN_FRONTEND=noninteractive
ENV USE_TWDS_MIRROR=${USE_TWDS_MIRROR}
RUN set -x \
    && groupadd --gid 99 bbs \
    && useradd -m -g bbs -s /bin/bash --uid 9999 bbs \
    && rm /etc/localtime \
    && ln -rsv /usr/share/zoneinfo/Asia/Taipei /etc/localtime

RUN env \
    && echo "Debian Version: $DEBIAN_VERSION ($DEBIAN_VERSION_NUMBER)" \
    && if [ "$DEBIAN_VERSION" = "bookworm" ]; then \
        LIBEVENT_PACKAGE="libevent-2.1"; \
    else \
        LIBEVENT_PACKAGE="libevent-2.1-7t64"; \
    fi \
    && if [ "$USE_TWDS_MIRROR" = 1 ]; then \
        sed -i 's|deb.debian.org|mirror.twds.com.tw|g' /etc/apt/sources.list.d/debian.sources; \
    fi \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        make \
        clang \
        gcc \
        g++ \
        libc6-dev \
        ca-certificates \
        python3 \
        python-is-python3 \
        "$LIBEVENT_PACKAGE" \
        libevent-dev \
        pkg-config \
        git \
        ccache \
        golang \
        ckati \
        ninja-build

############ stage 1-2
FROM pttbbs-builder-base AS pttbbs-builder
USER bbs
WORKDIR /home/bbs
RUN bash /tmp/build_ptt.sh

############ stage 2

FROM docker.io/library/debian:${MY_DEBIAN_VERSION}-slim AS stage-fileselector
COPY --from=pttbbs-builder /home/bbs /home/bbs
RUN rm -rvf /home/bbs/pttbbs
RUN rm -rvf /home/bbs/.cache

############ stage 3

FROM docker.io/library/debian:${MY_DEBIAN_VERSION}-slim
COPY --from=stage-fileselector /home/bbs /home/bbs

ARG MY_DEBIAN_VERSION
ENV DEBIAN_VERSION=${MY_DEBIAN_VERSION}
RUN set -x \
    && groupadd --gid 99 bbs \
    && useradd -m -g bbs -s /bin/bash --uid 9999 bbs \
    && rm /etc/localtime \
    && ln -rsv /usr/share/zoneinfo/Asia/Taipei /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        "libevent-2.1$(if [ $DEBIAN_VERSION = trixie ];then echo "-7t64";fi)" \
    && apt-get clean \
    && rm -rvf /var/cache/apt/archives /var/lib/apt/lists/*

USER bbs
CMD ["sh","-c","/home/bbs/bin/shmctl init && /home/bbs/bin/logind -D"]
EXPOSE 8888
