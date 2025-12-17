#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "${SCRIPT_DIR}/env.sh"

# Check arguments
if [ $# -eq 0 ]
then
    echo "Error: Please specify the virtual environment to activate."
    echo "Usage: penv activate <virtual_env_name>"
    exit 1
fi

# Virtual environment name
VIRTUAL_ENV_NAME=$1

# Validate virtual environment name (no special characters except - and _)
if [[ ! "$VIRTUAL_ENV_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "Error: Invalid virtual environment name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
    exit 1
fi

# Check if virtual environment exists
if [ ! -d "${VENV_STORAGE_DIR}/$VIRTUAL_ENV_NAME" ]
then
    echo "Error: Virtual environment '$VIRTUAL_ENV_NAME' does not exist."
    exit 1
fi

# Activate virtual environment - properly quote arguments to prevent injection
expect "${SCRIPT_DIR}/activate.exp" "$VIRTUAL_ENV_NAME" "${VENV_STORAGE_DIR}"