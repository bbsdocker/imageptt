FROM bbsdocker/debian_flatc:latest
MAINTAINER holishing
COPY pttbbs_conf /tmp/pttbbs.conf
COPY bindports_conf /tmp/bindports.conf
COPY nginx_conf_ws /tmp/nginx.conf
COPY webpack_config_js /tmp/webpack.config.js

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
    && ( curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - ) \
    && ( echo "deb http://openresty.org/package/debian $(lsb_release -sc) openresty" | tee /etc/apt/sources.list.d/openresty.list ) \
    && ( echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list ) \
    && ( curl -sL https://deb.nodesource.com/setup_12.x | bash - ) \
    && apt-get -y install --no-install-recommends openresty yarn nodejs \
    && cp /tmp/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf \
    && cd /usr/local/openresty/nginx/html/ \
    && git clone https://github.com/robertabcd/PttChrome.git /usr/local/openresty/nginx/html/PttChrome \
    && cp /tmp/webpack.config.js /usr/local/openresty/nginx/html/PttChrome/webpack.config.js \
    && cd /usr/local/openresty/nginx/html/PttChrome \
    && yarn && yarn build \
    && cp -r /usr/local/openresty/nginx/html/PttChrome/dist/* /usr/local/openresty/nginx/html

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
    && git clone https://github.com/toxicfrog/vstruct.git /home/bbs/wsproxy/lib/vstruct

USER root
CMD ["sh","-c","sudo -iu bbs /home/bbs/bin/shmctl init && sudo -iu bbs /home/bbs/bin/logind && /usr/bin/openresty -g 'daemon off;'"]
EXPOSE 8888
EXPOSE 48763
