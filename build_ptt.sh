#!/usr/bin/env bash

export BBSHOME=${HOME}

# check environment
env

set -eux

## clone current repo, build and install it
git clone https://github.com/ptt/pttbbs.git ${BBSHOME}/pttbbs
cd ${BBSHOME}/pttbbs
cp -v /tmp/confs/pttbbs_conf ${BBSHOME}/pttbbs/pttbbs.conf
cp -v /tmp/confs/initbbs_c ${BBSHOME}/pttbbs/util/initbbs.c
git apply /tmp/patches/*.patch
GLIBC_2_VERSION=$(ldd --version | grep GLIBC | sed 's/.*2\.//g')
if (( ${GLIBC_2_VERSION} < 38 )); then
    echo "#define NEED_STRLCPY" | tee -a ${BBSHOME}/pttbbs/pttbbs.conf
    echo "#define NEED_STRLCAT" | tee -a ${BBSHOME}/pttbbs/pttbbs.conf
fi
# use "pmake" as alias for supporting bmake using NetBSD specific Makefile rules 
pmake all install

## install logind for enabling websocket feature
cd ${BBSHOME}/pttbbs/daemon/logind
pmake all install

## Bootstrap sample BBS theme
cd ${BBSHOME}/pttbbs/sample
pmake install
cp -v etc/reg.methods ${BBSHOME}/etc/

## Clear object near source code
cd ${BBSHOME}/pttbbs
pmake clean

## Startup basic BBS Structure
${BBSHOME}/bin/initbbs -DoIt

## install configurations of telnet/websocket connection service
cp -v /tmp/confs/bindports_conf ${BBSHOME}/etc/bindports.conf
cp -vr ${BBSHOME}/pttbbs/daemon/wsproxy ${BBSHOME}/wsproxy
