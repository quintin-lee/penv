#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "${SCRIPT_DIR}/env.sh"

# Use arrays for safer file iteration
ACTIVATE_FILES=("${VENV_STORAGE_DIR}"/*.activate)
PID_FILES=("${VENV_STORAGE_DIR}"/*.pid)

PARENT_PID=$(ps -o ppid= -p $$)
PARENT_PID=$(echo $(ps -o ppid= -p $PARENT_PID) | cut -f2)

# Only process if files exist
if [[ -e "${ACTIVATE_FILES[0]}" ]]; then
    for file in "${ACTIVATE_FILES[@]}"; do
        [[ -f "$file" ]] && rm -f "$file"
    done
fi

if [[ -e "${PID_FILES[0]}" ]]; then
    for file in "${PID_FILES[@]}"; do
        [[ -f "$file" ]] && {
            PID=$(basename "$file" | cut -d'.' -f 1)
            rm -f "$file"
            if [[ "$PID" != "$PARENT_PID" ]]; then
                if ps -p "$PID" > /dev/null 2>&1; then
                    kill -9 "$PID" 2>/dev/null || true
                fi
            fi
        }
    done
fi

if [[ -n "$CURRENT_ENV" ]]; then
    kill -9 "$PARENT_PID" 2>/dev/null || true
fi