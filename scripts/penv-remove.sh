#!/usr/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

source ${SCRIPT_DIR}/env.sh

# Check arguments
if [ $# -eq 0 ]
then
    echo "Warning: Please specify the virtual environment to remove."
    exit 1
fi

VIRTUAL_ENV_NAME=$1

# Check if virtual environment exists and remove it
if [ -d "${VENV_STORAGE_DIR}/$VIRTUAL_ENV_NAME" ]
then
    rm -rf ${VENV_STORAGE_DIR}/$VIRTUAL_ENV_NAME
    if [ $? -eq 0 ]; then
        echo "Virtual environment '$VIRTUAL_ENV_NAME' has been successfully deleted."
    else
        echo "Error: Failed to delete virtual environment '$VIRTUAL_ENV_NAME'."
        exit 1
    fi
else
    echo "Error: Virtual environment '$VIRTUAL_ENV_NAME' does not exists."
    exit 1
fi