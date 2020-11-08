#!/bin/sh

set -eux

export BBSHOME=${HOME}

env
git clone https://github.com/ptt/pttbbs.git ${BBSHOME}/pttbbs
cd ${BBSHOME}/pttbbs
cp /tmp/pttbbs.conf ${BBSHOME}/pttbbs/pttbbs.conf
cd ${BBSHOME}/pttbbs && bmake all install \
cd ${BBSHOME}/pttbbs/daemon/logind && bmake all install \
cd ${BBSHOME}/pttbbs/sample \
bmake install \
${BBSHOME}/bin/initbbs -DoIt \
cp /tmp/bindports.conf ${BBSHOME}/etc/bindports.conf \
cp -r ${BBSHOME}/pttbbs/daemon/wsproxy ${BBSHOME}/wsproxy \
git clone https://github.com/toxicfrog/vstruct.git ${BBSHOME}/wsproxy/lib/vstruct
