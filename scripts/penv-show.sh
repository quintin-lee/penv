#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "${SCRIPT_DIR}/env.sh"

CURRENT_ENV=$CURRENT_ENV

for f in "${VENV_STORAGE_DIR}"/*.activate
do
    # Skip if no matches found - suppress error if no files match
    if [[ -f "$f" ]]; then
        FILENAME=$(basename "$f")
        ENV=$(echo "$FILENAME" | cut -d'.' -f1)
        if [ "$ENV" == "$CURRENT_ENV" ]; then
            echo "   *$ENV*"
        else
            echo "    $ENV"
        fi
    else
        continue
    fi
done