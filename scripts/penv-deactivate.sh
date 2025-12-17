#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "${SCRIPT_DIR}/env.sh"

# Use ps command to get the parent process PID
PARENT_PID=$(ps -o ppid= -p $$)
PARENT_PID=$(echo $(ps -o ppid= -p $PARENT_PID) | cut -f2)

if [[ -n "$CURRENT_ENV" ]]
then
    FILE="${VENV_STORAGE_DIR}/${CURRENT_ENV}.activate"
    if [[ -f "$FILE" ]]
    then
        NUM=$(cat "$FILE")
        if [[ "$NUM" =~ ^[0-9]+$ ]]; then
            NUM=$((NUM - 1))
            if [ $NUM -eq 0 ]
            then
                rm -f "$FILE"
            else
                echo "$NUM" > "$FILE"
            fi
        else
            echo "Warning: Invalid content in activation file" >&2
            exit 1
        fi
    fi

    PID_FILE="${VENV_STORAGE_DIR}/${PARENT_PID}.pid"
    # pid file
    if [[ -f "$PID_FILE" ]]
    then
        rm -f "$PID_FILE"
        kill -9 "$PARENT_PID" 2>/dev/null || true
    fi
else
    exit 1
fi