FROM debian:buster
MAINTAINER holishing
COPY pttbbs_conf /tmp/pttbbs.conf

RUN groupadd --gid 99 bbs \
    && useradd -g bbs -s /bin/bash --uid 9999 bbs \
    && mkdir /home/bbs \
    && chown -R bbs:bbs /home/bbs \
    && rm /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Taipei /etc/localtime \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        bmake \
        gcc \
        g++ \
        libc6-dev \
        curl \
        ca-certificates \
        libevent-dev \
        pkg-config \
        python \
        git \
        ccache \
        clang

USER bbs
ENV HOME=/home/bbs
RUN cd /home/bbs \
    && git clone https://github.com/ptt/pttbbs.git pttbbs \
    && cd /home/bbs/pttbbs \
    && cp /tmp/pttbbs.conf /home/bbs/pttbbs/pttbbs.conf \
    && cd /home/bbs/pttbbs && bmake all install clean \
    && cd /home/bbs/pttbbs/sample \
    && bmake install \
    && /home/bbs/bin/initbbs -DoIt

CMD ["sh","-c","/home/bbs/bin/shmctl init && /home/bbs/bin/mbbsd -d -p 8888 && /home/bbs/bin/mbbsd -d -e utf8 -p 8889 && while true; do sleep 10; done"]
EXPOSE 8888
EXPOSE 8889
