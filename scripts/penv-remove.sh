#!/usr/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

source ${SCRIPT_DIR}/env.sh

if [ $# -eq 0 ]
then
    echo "Warning: Please specify the virtual environment to remove."
    exit 1
fi

virtual_env_name=$1

if [ -d "${VENV_STORAGE_DIR}/$virtual_env_name" ]
then
    rm -rf ${VENV_STORAGE_DIR}/$virtual_env_name
    echo "Virtual environment '$virtual_env_name' has been successfully deleted."
else
    echo "Error: Virtual environment '$virtual_env_name' does not exists."
fi
