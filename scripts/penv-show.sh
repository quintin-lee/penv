#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source ${SCRIPT_DIR}/env.sh

CURRENT_ENV=$CURRENT_ENV

for f in $(ls ${VENV_STORAGE_DIR}/*.activate 2>/dev/null)
do
    FILENAME=$(basename $f)
    ENV=$(echo $FILENAME | cut -d'.' -f1)
    if [ "$ENV" == "$CURRENT_ENV" ]; then
        echo "   *$ENV*"
    else
        echo "    $ENV"
    fi
done