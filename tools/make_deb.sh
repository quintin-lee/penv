#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")/..

VERSION=0.1.1
DIST_DIR=${SCRIPT_DIR}/dist
DEBIAN_DIR=${DIST_DIR}/DEBIAN
BIN_DIR=${DIST_DIR}/usr/bin
OPT_DIR=${DIST_DIR}/opt/penv
SERVICE_DIR=${DIST_DIR}/etc/systemd/system
BASH_COMPLETION_DIR=${DIST_DIR}/usr/share/bash-completion/completions
ZSH_COMPLETION_DIR=${DIST_DIR}/usr/share/zsh/site-functions

# create dist dir
[ ! -d ${DIST_DIR} ] && mkdir -p $DIST_DIR
[ ! -d ${DEBIAN_DIR} ] && mkdir -p $DEBIAN_DIR
[ ! -d ${BIN_DIR} ] && mkdir -p $BIN_DIR
[ ! -d ${OPT_DIR} ] && mkdir -p $OPT_DIR
[ ! -d ${SERVICE_DIR} ] && mkdir -p $SERVICE_DIR
[ ! -d ${BASH_COMPLETION_DIR} ] && mkdir -p $BASH_COMPLETION_DIR
[ ! -d ${ZSH_COMPLETION_DIR} ] && mkdir -p $ZSH_COMPLETION_DIR

# copy files to dist
cp ${SCRIPT_DIR}/penv ${OPT_DIR}
cp -r ${SCRIPT_DIR}/scripts ${OPT_DIR}

cp ${SCRIPT_DIR}/scripts/penv.service ${SERVICE_DIR}

# copy completion files
cp ${SCRIPT_DIR}/scripts/penv-completion.bash ${BASH_COMPLETION_DIR}/penv
cp ${SCRIPT_DIR}/scripts/penv-completion.bash ${ZSH_COMPLETION_DIR}/_penv

(cd ${BIN_DIR}; ln -sf ../../opt/penv/penv .)

# create control file
cat << EOF > ${DEBIAN_DIR}/control 
Package: penv
Version: ${VERSION}
Section: base
Priority: optional
Architecture: all
Depends: bash, expect, python3
Maintainer: quintin <2449164582@qq.com>
Description: Python venv management tool
 This package provides commands for create, list, remove, activate, deactivate and clean virtual environments.
Homepage: https://github.com/quintin-lee/penv
EOF

# Add postinst script for completion setup
cat << 'EOF' > ${DEBIAN_DIR}/postinst
#!/bin/bash
set -e

# Function to update shell completion
_update_completion() {
    # For bash users
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
        source /usr/share/bash-completion/bash_completion 2>/dev/null || true
    fi
    
    # For zsh users
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        # Refresh command hash
        hash -r 2>/dev/null || true
    fi
}

# Reload systemd daemon to recognize new service
systemctl daemon-reload

# Enable the service
systemctl enable penv.service --now

# Update completion for both bash and zsh
_update_completion

exit 0
EOF

# Add postrm script for cleanup
cat << 'EOF' > ${DEBIAN_DIR}/postrm
#!/bin/bash
set -e

if [ "$1" = "remove" ]; then
    # Stop and disable the service before removing
    if systemctl is-active --quiet penv.service; then
        systemctl stop penv.service
    fi
    
    if systemctl is-enabled --quiet penv.service; then
        systemctl disable penv.service
    fi
    
    # Reload systemd daemon to forget about the service
    systemctl daemon-reload
    
    # Reset failed units if any
    systemctl reset-failed
fi

exit 0
EOF

# Add preinst script
cat << 'EOF' > ${DEBIAN_DIR}/preinst
#!/bin/bash
set -e

# Nothing to do here

exit 0
EOF

# Add prerm script
cat << 'EOF' > ${DEBIAN_DIR}/prerm
#!/bin/bash
set -e

# Stop and disable the service before removing
if systemctl is-active --quiet penv.service; then
    systemctl stop penv.service
fi

if systemctl is-enabled --quiet penv.service; then
    systemctl disable penv.service
fi

exit 0
EOF

# Make scripts executable
chmod 755 ${DEBIAN_DIR}/postinst
chmod 755 ${DEBIAN_DIR}/postrm
chmod 755 ${DEBIAN_DIR}/preinst
chmod 755 ${DEBIAN_DIR}/prerm

# generate deb
sudo dpkg -b $DIST_DIR $SCRIPT_DIR/penv_${VERSION}-all.deb