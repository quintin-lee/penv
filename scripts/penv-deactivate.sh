#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "${SCRIPT_DIR}/env.sh"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: penv deactivate"
    echo ""
    echo "Deactivate the current virtual environment."
    echo ""
    echo "Decrements the activation counter and cleans up"
    echo "the activation marker."
    echo ""
    echo "Example:"
    echo "  penv deactivate"
    exit 0
fi

# Use ps command to get the parent process PID
PARENT_PID=$(ps -o ppid= -p $$)
PARENT_PID=$(ps -o ppid= -p "$PARENT_PID" | cut -f2)

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
            die "Invalid content in activation file"
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
    die "No active environment to deactivate."
fi