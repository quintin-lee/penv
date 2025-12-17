#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source ${SCRIPT_DIR}/env.sh

# Ensure virtual environment storage directory exists
if [ ! -d "${VENV_STORAGE_DIR}" ]; then
    mkdir -p ${VENV_STORAGE_DIR}
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create virtual environment storage directory '${VENV_STORAGE_DIR}'."
        exit 1
    fi
fi

# Check arguments
if [ $# -lt 1 ]; then
    echo "Error: No virtual environment name provided."
    echo "Usage: $0 <virtual_env_name> [description]"
    exit 1
fi

# Virtual environment name
VIRTUAL_ENV_NAME=$1

# Validate virtual environment name (no special characters except - and _)
if [[ ! "$VIRTUAL_ENV_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "Error: Invalid virtual environment name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
    exit 1
fi

# Description information (optional)
DESCRIPTION="${2:-}"

# Check if virtual environment already exists
if [ -d "${VENV_STORAGE_DIR}/$VIRTUAL_ENV_NAME" ]; then
    echo "Error: Virtual environment '$VIRTUAL_ENV_NAME' already exists."
    exit 1
fi

# Check if Python3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python3 is not installed."
    exit 1
fi

SELECTED_PYTHON=""
# Call select_python_version.sh script and capture output with timeout
if timeout 30s ${SCRIPT_DIR}/select_version.sh > /tmp/penv_select_output.$$ 2>&1; then
    while IFS= read -r LINE
    do
        if [[ -f ${LINE} ]]
        then
            SELECTED_PYTHON=$LINE
            continue
        fi
        if [[ -n $(echo ${LINE} | grep ':' | grep -v '^-') ]]
        then
            echo "   ${LINE}"
            continue
        fi
        echo "$LINE"
    done < /tmp/penv_select_output.$$
    rm -f /tmp/penv_select_output.$$
else
    echo "Error: Timeout or error occurred during Python version selection. Using default python3."
    rm -f /tmp/penv_select_output.$$
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
    echo "Error: Failed to create virtual environment '$VIRTUAL_ENV_NAME'."
    exit 1
fi

# Write description with proper quote handling
if ! printf "%s\n" "$DESCRIPTION" > "${VENV_STORAGE_DIR}/$VIRTUAL_ENV_NAME/description.txt"; then
    echo "Warning: Failed to write description to virtual environment."
fi

echo "Virtual environment '$VIRTUAL_ENV_NAME' created successfully."