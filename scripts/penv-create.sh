#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "${SCRIPT_DIR}/env.sh"

# Ensure virtual environment storage directory exists
if [ ! -d "${VENV_STORAGE_DIR}" ]; then
    if ! mkdir -p "${VENV_STORAGE_DIR}"; then
        die "Failed to create virtual environment storage directory '${VENV_STORAGE_DIR}'."
    fi
fi

# Check arguments
if [ $# -lt 1 ]; then
    die "No virtual environment name provided."
    echo "Usage: $0 <virtual_env_name> [description]"
fi

# Virtual environment name
VIRTUAL_ENV_NAME=$1

# Validate virtual environment name (no special characters except - and _)
if [[ ! "$VIRTUAL_ENV_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    die "Invalid virtual environment name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
fi

# Description information (optional)
DESCRIPTION="${2:-}"

# Check if virtual environment already exists
if [ -d "${VENV_STORAGE_DIR}/$VIRTUAL_ENV_NAME" ]; then
    die "Virtual environment '$VIRTUAL_ENV_NAME' already exists."
fi

# Check if Python3 is installed
if ! command -v python3 &> /dev/null; then
    die "Python3 is not installed."
fi

SELECTED_PYTHON=""
# Call select_python_version.sh script and capture output with timeout
TMPFILE=$(mktemp /tmp/penv_select.XXXXXX 2>/dev/null) || die "Failed to create temp file"
if timeout 30s "${SCRIPT_DIR}/select_version.sh" > "$TMPFILE" 2>&1; then
    while IFS= read -r LINE
    do
        if [[ -f ${LINE} ]]
        then
            SELECTED_PYTHON=$LINE
            continue
        fi
        if grep -q ':' <<< "$LINE" && ! grep -q '^-' <<< "$LINE"; then
            echo "   ${LINE}"
            continue
        fi
        echo "$LINE"
    done < "$TMPFILE"
    rm -f "$TMPFILE"
else
    echo "Error: Timeout or error occurred during Python version selection. Using default python3."
    rm -f "$TMPFILE"
fi

# Check if a Python version was selected
if [[ -n "$SELECTED_PYTHON" ]]; then
    CMD=$SELECTED_PYTHON
    # Can continue processing the selected Python version here
else
    CMD="python3"
fi

echo "Creating virtual environment '$VIRTUAL_ENV_NAME'..."
# Create the virtual environment
if ! "$CMD" -m venv "${VENV_STORAGE_DIR}/$VIRTUAL_ENV_NAME"; then
    die "Failed to create virtual environment '$VIRTUAL_ENV_NAME'."
fi

# Write description with proper quote handling
if ! printf "%s\n" "$DESCRIPTION" > "${VENV_STORAGE_DIR}/$VIRTUAL_ENV_NAME/description.txt"; then
    echo "Warning: Failed to write description to virtual environment."
fi

echo "Virtual environment '$VIRTUAL_ENV_NAME' created successfully."