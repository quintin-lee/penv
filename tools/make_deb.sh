#!/usr/bin/bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")/..

VERSION=0.1
DIST_DIR=${SCRIPT_DIR}/dist
DEBIAN_DIR=${DIST_DIR}/DEBIAN
BIN_DIR=${DIST_DIR}/usr/bin
OPT_DIR=${DIST_DIR}/opt/penv

# create dist dir
[ ! -d ${DIST_DIR} ] && mkdir -p $DIST_DIR
[ ! -d ${DEBIAN_DIR} ] && mkdir -p $DEBIAN_DIR
[ ! -d ${BIN_DIR} ] && mkdir -p $BIN_DIR
[ ! -d ${OPT_DIR} ] && mkdir -p $OPT_DIR

# copy files to dist
cp ${SCRIPT_DIR}/penv ${OPT_DIR}
cp -r ${SCRIPT_DIR}/scripts ${OPT_DIR}

(cd ${BIN_DIR}; ln -sf ../../opt/penv/penv .)

# create control file
cat << EOF > ${DEBIAN_DIR}/control 
Package: penv
Version: ${VERSION}
Section: base
Priority: optional
Architecture: all
Depends: bash, expect
Maintainer: quintin <2449164582@qq.com>
Description: Python venv management tool
 This package provides commands for create, list, show, remove, activate, deactivate and clean virtual environments.
EOF

# generate deb
sudo dpkg -b $DIST_DIR $SCRIPT_DIR/penv_${VERSION}-all.deb
