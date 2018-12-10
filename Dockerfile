FROM debian:buster
MAINTAINER holishing

RUN groupadd --gid 99 bbs \
    && useradd -g bbs -s /bin/bash --uid 9999 bbs \
    && mkdir /home/bbs \
    && chown -R bbs:bbs /home/bbs \
    && rm /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Taipei /etc/localtime

RUN apt update \
    && apt upgrade -y \
    && apt-get install -y --no-install-recommends \
        bmake \
        ccache \
        clang \
        curl \
        ca-certificates \
        libevent-dev \
        pkg-config \
        python

USER bbs
ENV HOME=/home/bbs
ARG GITVER=993daabfea9a0428672b0606c5d52e34bfe27c51

RUN cd /home/bbs \
    && sh -c "curl -L https://github.com/my1938/BRsBBS/archive/$GITVER.tar.gz | tar -zxv" \
    && mv BRsBBS-$GITVER BRsBBS \
    && cd /home/bbs/BRsBBS 
COPY file/pttbbs_conf /home/bbs/BRsBBS/pttbbs.conf
RUN cd /home/bbs/BRsBBS && bmake all install clean

RUN cd /home/bbs/BRsBBS/sample \
    && bmake install \
    && /home/bbs/bin/initbbs -DoIt

CMD ["sh","-c","/home/bbs/bin/shmctl init && /home/bbs/bin/mbbsd -d -p 8888 && /home/bbs/bin/mbbsd -d -e utf8 -p 8889 && while true; do sleep 10; done"]
EXPOSE 8888
EXPOSE 8889
