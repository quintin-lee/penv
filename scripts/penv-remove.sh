#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

source ${SCRIPT_DIR}/env.sh

# Check arguments
if [ $# -eq 0 ]
then
    echo "Warning: Please specify the virtual environment to remove."
    echo "Usage: penv remove <virtual_env_name>"
    exit 1
fi

VIRTUAL_ENV_NAME=$1

# Validate virtual environment name (no special characters except - and _)
if [[ ! "$VIRTUAL_ENV_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "Error: Invalid virtual environment name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
    exit 1
fi

# Check if virtual environment exists and remove it
if [ -d "${VENV_STORAGE_DIR}/$VIRTUAL_ENV_NAME" ]
then
    echo "Removing virtual environment '$VIRTUAL_ENV_NAME'..."
    rm -rf ${VENV_STORAGE_DIR}/$VIRTUAL_ENV_NAME
    if [ $? -eq 0 ]; then
        echo "Virtual environment '$VIRTUAL_ENV_NAME' has been successfully deleted."
    else
        echo "Error: Failed to delete virtual environment '$VIRTUAL_ENV_NAME'."
        exit 1
    fi
else
    echo "Error: Virtual environment '$VIRTUAL_ENV_NAME' does not exist."
    exit 1
fi