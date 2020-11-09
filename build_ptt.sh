#!/bin/sh

set -eux

export BBSHOME=${HOME}

# check environment
env

## clone current repo, build and install it
git clone https://github.com/holishing/pttbbs.git ${BBSHOME}/pttbbs
cd ${BBSHOME}/pttbbs
git checkout r2/letflatcoptional
cp /tmp/pttbbs.conf ${BBSHOME}/pttbbs/pttbbs.conf
bmake all install

## install logind for enabling websocket feature
cd ${BBSHOME}/pttbbs/daemon/logind
bmake all install

## Bootstrap sample BBS theme
cd ${BBSHOME}/pttbbs/sample
bmake install

## Clear object near source code
cd ${BBSHOME}/pttbbs
bmake clean

## Startup basic BBS Structure
${BBSHOME}/bin/initbbs -DoIt

## install configurations of telnet/websocket connection service
cp /tmp/bindports.conf ${BBSHOME}/etc/bindports.conf
cp -r ${BBSHOME}/pttbbs/daemon/wsproxy ${BBSHOME}/wsproxy
git clone https://github.com/toxicfrog/vstruct.git ${BBSHOME}/wsproxy/lib/vstruct
