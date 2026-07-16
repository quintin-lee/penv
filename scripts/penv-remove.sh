#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "${SCRIPT_DIR}/env.sh"

# Check arguments
if [ $# -eq 0 ]
then
    die "Please specify the virtual environment to remove."
    echo "Usage: penv remove <virtual_env_name>"
fi

VIRTUAL_ENV_NAME=$1

# Validate virtual environment name (no special characters except - and _)
if [[ ! "$VIRTUAL_ENV_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    die "Invalid virtual environment name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
fi

# Check if virtual environment exists and remove it
if [ -d "${VENV_STORAGE_DIR}/$VIRTUAL_ENV_NAME" ]
then
    # Additional safety check to ensure we're only removing legitimate venv directories
    if [[ "${VENV_STORAGE_DIR}" == *"/.cache/python-venv" || "${VENV_STORAGE_DIR}" == "$HOME"* || "${VENV_STORAGE_DIR}" == "/tmp/"* ]]; then
        echo "Removing virtual environment '$VIRTUAL_ENV_NAME'..."
        if rm -rf "${VENV_STORAGE_DIR:?}/${VIRTUAL_ENV_NAME:?}"; then
            echo "Virtual environment '$VIRTUAL_ENV_NAME' has been successfully deleted."
        else
            die "Failed to delete virtual environment '$VIRTUAL_ENV_NAME'."
        fi
    else
        die "Safety check failed. VENV_STORAGE_DIR appears to be misconfigured."
    fi
else
    die "Virtual environment '$VIRTUAL_ENV_NAME' does not exist."
fi