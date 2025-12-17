#!/usr/bin/env bash

# Set the virtual environment storage directory with a default
VENV_STORAGE_DIR=${VENV_STORAGE_DIR:-"$HOME/.cache/python-venv"}

# Create the directory if it doesn't exist
if [[ ! -d "$VENV_STORAGE_DIR" ]]; then
    if ! mkdir -p "$VENV_STORAGE_DIR"; then
        echo "Error: Cannot create VENV_STORAGE_DIR: $VENV_STORAGE_DIR" >&2
        exit 1
    fi
fi