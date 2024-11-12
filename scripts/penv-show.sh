#!/usr/bin/bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source ${SCRIPT_DIR}/env.sh

current_env=$CURRENT_ENV

for f in $(ls ${VENV_STORAGE_DIR}/*.activate 2>/dev/null)
do
    filename=$(basename $f)
    env=$(echo $filename | cut -d'.' -f1)
    if [ "$env" == "$current_env" ]; then
        echo "   *$env*"
    else
        echo "    $env"
    fi
done
