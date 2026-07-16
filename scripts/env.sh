#!/usr/bin/env bash

# Unified error handler — prints to stderr and exits
die() {
    echo "Error: $*" >&2
    exit 1
}

# Set the virtual environment storage directory with a default
VENV_STORAGE_DIR=${VENV_STORAGE_DIR:-"$HOME/.cache/python-venv"}

# Create the directory if it doesn't exist
if [[ ! -d "$VENV_STORAGE_DIR" ]]; then
    if ! mkdir -p "$VENV_STORAGE_DIR"; then
        die "Cannot create VENV_STORAGE_DIR: $VENV_STORAGE_DIR"
    fi
fi