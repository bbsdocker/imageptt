ARG MY_DEBIAN_VERSION
FROM debian:${MY_DEBIAN_VERSION}
MAINTAINER holishing
COPY pttbbs_conf /tmp/pttbbs.conf
COPY bindports_conf /tmp/bindports.conf
COPY nginx_conf_ws /tmp/nginx.conf
COPY build_ptt.sh /tmp/build_ptt.sh
COPY multipledef.patch /tmp/multipledef.patch

ARG MY_DEBIAN_VERSION
ENV DEBIAN_VERSION $MY_DEBIAN_VERSION
RUN set -x \
    && groupadd --gid 99 bbs \
    && useradd -m -g bbs -s /bin/bash --uid 9999 bbs \
    && rm /etc/localtime \
    && ln -rsv /usr/share/zoneinfo/Asia/Taipei /etc/localtime \
    && cat /etc/apt/sources.list \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
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
        sudo \
        libio-all-perl \
        libemail-sender-perl \
    && ( curl -L https://openresty.org/package/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/openresty-archive-keyring.gpg ) \
    && ( echo "deb [signed-by=/usr/share/keyrings/openresty-archive-keyring.gpg] http://openresty.org/package/debian ${DEBIAN_VERSION} openresty" | tee /etc/apt/sources.list.d/openresty.list ) \
    && apt-get update \
    && apt-get -y install --no-install-recommends openresty \
    && cp /tmp/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf \
    && sudo -iu bbs sh /tmp/build_ptt.sh \
    && apt-get remove -y bmake gcc g++ clang ccache libc6-dev libevent-dev pkg-config gnupg \
    && apt-get autoremove -y

USER root
CMD ["sh","-c","sudo -iu bbs /home/bbs/bin/shmctl init && sudo -iu bbs /home/bbs/bin/logind && /usr/bin/openresty -g 'daemon off;'"]
EXPOSE 8888
EXPOSE 48763
