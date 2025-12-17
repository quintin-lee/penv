#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Trap signals to exit gracefully
trap "exit 0" SIGTERM SIGINT

while true
do
    if ! "${SCRIPT_DIR}/penv-clean.sh"; then
        echo "Warning: penv-clean.sh failed" >&2
    fi
    sleep 60
done