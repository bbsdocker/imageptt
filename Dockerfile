FROM debian:buster
MAINTAINER holishing
COPY pttbbs_conf /tmp/pttbbs.conf
COPY bindports_conf /tmp/bindports.conf

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
        clang \
        wget \
        gnupg \
        lsb-release \
        sudo \
    && ( wget -O - https://openresty.org/package/pubkey.gpg | apt-key add - ) \
    && ( echo "deb http://openresty.org/package/debian $(lsb_release -sc) openresty" | tee /etc/apt/sources.list.d/openresty.list ) \
    && apt-get update \
    && apt-get -y install --no-install-recommends openresty

USER bbs
ENV HOME=/home/bbs
RUN cd /home/bbs \
    && git clone https://github.com/ptt/pttbbs.git pttbbs \
    && cd /home/bbs/pttbbs \
    && cp /tmp/pttbbs.conf /home/bbs/pttbbs/pttbbs.conf \
    && cd /home/bbs/pttbbs && bmake all install \
    && cd /home/bbs/pttbbs/daemon/logind && bmake all install \
    && cd /home/bbs/pttbbs/sample \
    && bmake install \
    && /home/bbs/bin/initbbs -DoIt \
    && cp /tmp/bindports.conf /home/bbs/etc/bindports.conf \
    && cp -r /home/bbs/pttbbs/daemon/wsproxy /home/bbs/wsproxy \
    && git clone https://github.com/toxicfrog/vstruct.git /home/bbs/wsproxy/lib


USER root
CMD ["sh","-c","sudo -iu bbs /home/bbs/bin/shmctl init && sudo -iu bbs /home/bbs/bin/logind && /usr/bin/openresty -g 'daemon off;'"]
EXPOSE 8888
EXPOSE 80
