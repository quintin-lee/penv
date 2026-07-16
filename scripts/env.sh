#!/usr/bin/env bash

# Unified error handler — prints to stderr and exits
die() {
    echo "Error: $*" >&2
    exit 1
}

# Load user config file if it exists
PENV_CONFIG_DIR="${HOME}/.config/penv"
PENV_CONFIG_FILE="${PENV_CONFIG_DIR}/config"
if [[ -f "$PENV_CONFIG_FILE" ]]; then
    while IFS='=' read -r key value; do
        [[ -z "$key" || "$key" == \#* ]] && continue
        case "$key" in
            storage_dir) VENV_STORAGE_DIR="$value" ;;
            default_python) # shellcheck disable=SC2034 # consumed by other scripts
                PENV_DEFAULT_PYTHON="$value" ;;
        esac
    done < "$PENV_CONFIG_FILE"
fi

# Set the virtual environment storage directory with a default
VENV_STORAGE_DIR=${VENV_STORAGE_DIR:-"$HOME/.cache/python-venv"}

# Default plugin directory (can be overridden via config or env var)
PENV_PLUGIN_DIR=${PENV_PLUGIN_DIR:-"${HOME}/.config/penv/plugins"}

# Create the directory if it doesn't exist
if [[ ! -d "$VENV_STORAGE_DIR" ]]; then
    if ! mkdir -p "$VENV_STORAGE_DIR"; then
        die "Cannot create VENV_STORAGE_DIR: $VENV_STORAGE_DIR"
    fi
fi