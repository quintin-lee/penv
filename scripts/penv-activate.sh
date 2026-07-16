#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "${SCRIPT_DIR}/env.sh"

# Check arguments
if [ $# -eq 0 ]
then
    die "Please specify the virtual environment to activate."
    echo "Usage: penv activate <virtual_env_name>"
fi

# Virtual environment name
VIRTUAL_ENV_NAME=$1

# Validate virtual environment name (no special characters except - and _)
if [[ ! "$VIRTUAL_ENV_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    die "Invalid virtual environment name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
fi

# Check if virtual environment exists
if [ ! -d "${VENV_STORAGE_DIR}/$VIRTUAL_ENV_NAME" ]
then
    die "Virtual environment '$VIRTUAL_ENV_NAME' does not exist."
fi

# Activate virtual environment - properly quote arguments to prevent injection
expect "${SCRIPT_DIR}/activate.exp" "$VIRTUAL_ENV_NAME" "${VENV_STORAGE_DIR}"