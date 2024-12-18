#!/usr/bin/bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

while true
do
    ${SCRIPT_DIR}/penv-clean.sh
    sleep 60
done
