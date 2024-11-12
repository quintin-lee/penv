#!/usr/bin/bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source ${SCRIPT_DIR}/env.sh

if [ -z "$1" ]
then
    echo "Usage: $0 <virtual_env_name>"
    exit 1
fi

virtual_env_name=$1

if [ ! -d "${VENV_STORAGE_DIR}/$virtual_env_name" ]; then
    echo "Error: Virtual environment '$virtual_env_name' does not exists."
    exit 1
fi

$SCRIPT_DIR/activate.exp ${virtual_env_name} ${VENV_STORAGE_DIR}

