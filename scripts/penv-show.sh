#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "${SCRIPT_DIR}/env.sh"

for f in "${VENV_STORAGE_DIR}"/*.activate
do
    # Skip if no matches found
    if [[ -f "$f" ]]; then
        FILENAME=$(basename "$f")
        ENV=$(echo "$FILENAME" | cut -d'.' -f1)
        echo "   *$ENV*"
    fi
done