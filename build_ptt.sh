#!/bin/sh

export BBSHOME=${HOME}

# check environment
env

set -eux

## clone current repo, build and install it
git clone https://github.com/ptt/pttbbs.git ${BBSHOME}/pttbbs
cd ${BBSHOME}/pttbbs
cp -v /tmp/pttbbs.conf ${BBSHOME}/pttbbs/pttbbs.conf
cp -v /tmp/initbbs.c ${BBSHOME}/pttbbs/util/initbbs.c
git apply /tmp/fix_contect_email_not_enabled.patch
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
cp -v /tmp/bindports.conf ${BBSHOME}/etc/bindports.conf
cp -vr ${BBSHOME}/pttbbs/daemon/wsproxy ${BBSHOME}/wsproxy
