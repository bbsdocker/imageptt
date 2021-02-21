#!/bin/sh

export BBSHOME=${HOME}
if [ "${DEBIAN_VERSION}" = "bullseye" ]; then alias bmake="bmake -m /usr/share/bmake/mk-netbsd/" ; fi

# check environment
env

set -eux

## clone current repo, build and install it
git clone https://github.com/ptt/pttbbs.git ${BBSHOME}/pttbbs
cd ${BBSHOME}/pttbbs
cp /tmp/pttbbs.conf ${BBSHOME}/pttbbs/pttbbs.conf
git apply /tmp/multipledef.patch
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
