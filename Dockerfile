ARG MY_DEBIAN_VERSION=trixie
FROM docker.io/library/debian:${MY_DEBIAN_VERSION} AS pttbbs-builder

COPY confs /tmp/confs
## if some bugs in new distro version, workaround here may be enabled:
#COPY patches /tmp/patches
COPY build_ptt.sh /tmp/build_ptt.sh

ENV DEBIAN_VERSION=${MY_DEBIAN_VERSION}
ENV DEBIAN_FRONTEND=noninteractive
RUN set -x \
    && groupadd --gid 99 bbs \
    && useradd -m -g bbs -s /bin/bash --uid 9999 bbs \
    && rm /etc/localtime \
    && ln -rsv /usr/share/zoneinfo/Asia/Taipei /etc/localtime

RUN if [ "$DEBIAN_VERSION" = "bookworm" ]; then \
        LIBEVENT_PACKAGE="libevent-2.1"; \
    else \
        LIBEVENT_PACKAGE="libevent-2.1-7t64"; \
    fi \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        bmake \
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
        golang

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
