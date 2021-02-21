#!/bin/sh

export BBSHOME=${HOME}

# check environment
env

set -eux

## clone current repo, build and install it
git clone https://github.com/ptt/pttbbs.git ${BBSHOME}/pttbbs
cd ${BBSHOME}/pttbbs
cp /tmp/pttbbs.conf ${BBSHOME}/pttbbs/pttbbs.conf
git apply /tmp/multipledef.patch
pmake all install

## install logind for enabling websocket feature
cd ${BBSHOME}/pttbbs/daemon/logind
pmake all install

## Bootstrap sample BBS theme
cd ${BBSHOME}/pttbbs/sample
pmake install

## Clear object near source code
cd ${BBSHOME}/pttbbs
pmake clean

## Startup basic BBS Structure
${BBSHOME}/bin/initbbs -DoIt

## install configurations of telnet/websocket connection service
cp /tmp/bindports.conf ${BBSHOME}/etc/bindports.conf
cp -r ${BBSHOME}/pttbbs/daemon/wsproxy ${BBSHOME}/wsproxy
