#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")/..

PENV_TAR=${SCRIPT_DIR}/penv.tar.gz

# create penv.tar.gz
[ -f ${PENV_TAR} ] && rm -f ${PENV_TAR}

(cd $SCRIPT_DIR; tar zcvf ${PENV_TAR} penv scripts)

# generate pkg
makepkg -f