FROM bbsdocker/debian_flatc:latest
MAINTAINER holishing
COPY pttbbs_conf /tmp/pttbbs.conf
COPY bindports_conf /tmp/bindports.conf
COPY nginx_conf_ws /tmp/nginx.conf
COPY build_ptt.sh /tmp/build_ptt.sh

RUN groupadd --gid 99 bbs \
    && useradd -m -g bbs -s /bin/bash --uid 9999 bbs \
    && rm /etc/localtime \
    && ln -rsv /usr/share/zoneinfo/Asia/Taipei /etc/localtime \
    && apt-get update \
    && apt-get -t buster-backports upgrade -y \
    && apt-get -t buster-backports install -y --no-install-recommends \
        bmake \
        gcc \
        g++ \
        libc6-dev \
        curl \
        ca-certificates \
        libevent-2.1 \
        libevent-dev \
        pkg-config \
        python \
        git \
        ccache \
        clang \
        gnupg \
        lsb-release \
        sudo \
    && ( curl -sS https://openresty.org/package/pubkey.gpg | apt-key add - ) \
    && ( echo "deb http://openresty.org/package/debian $(lsb_release -sc) openresty" | tee /etc/apt/sources.list.d/openresty.list ) \
    && apt-get update \
    && apt-get -y install --no-install-recommends openresty \
    && cp /tmp/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf \
    && sudo -iu bbs sh /tmp/build_ptt.sh \
    && apt-get remove -y bmake gcc g++ libc6-dev libevent-dev pkg-config gnupg \
    && apt-get autoremove -y

USER root
CMD ["sh","-c","sudo -iu bbs /home/bbs/bin/shmctl init && sudo -iu bbs /home/bbs/bin/logind && /usr/bin/openresty -g 'daemon off;'"]
EXPOSE 8888
EXPOSE 48763
