#!/usr/bin/env bash

export BBSHOME=${HOME}

# check environment
env

set -eux

## clone current repo, build and install it
git clone https://github.com/ptt/pttbbs.git ${BBSHOME}/pttbbs
cp -v /tmp/confs/pttbbs_conf ${BBSHOME}/pttbbs/pttbbs.conf
cp -v /tmp/confs/initbbs_c ${BBSHOME}/pttbbs/util/initbbs.c
cd ${BBSHOME}/pttbbs
## if some bugs in new distro version, workaround here may be enabled:
git apply /tmp/patches/*.patch
make CFLAGS+=" -fsigned-char"
make install

## install logind for enabling websocket feature
cd ${BBSHOME}/pttbbs/daemon/logind
make CFLAGS+=" -fsigned-char"
make install

## Bootstrap sample BBS theme
cd ${BBSHOME}/pttbbs/sample
make install
cp -v etc/reg.methods ${BBSHOME}/etc/

## Clear object near source code
cd ${BBSHOME}/pttbbs
make clean

## Startup basic BBS Structure
${BBSHOME}/bin/initbbs -DoIt

## install configurations of telnet/websocket connection service
cp -v /tmp/confs/bindports_conf ${BBSHOME}/etc/bindports.conf
cp -vr ${BBSHOME}/pttbbs/daemon/wsproxy ${BBSHOME}/wsproxy
