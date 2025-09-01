#!/usr/bin/bash
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
if [ $# -lt 2 ]; then
    echo "Error: No virtual environment name or description provided."
    echo "Usage: $0 <virtual_env_name> <description>"
    exit 1
fi

ALL_ARGS=("$@")

# Virtual environment name
VIRTUAL_ENV_NAME=${ALL_ARGS[0]}
# Description information
DESCRIPTION="${ALL_ARGS[1]}"

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
# Call select_python_version.sh script and capture output
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
done < <(${SCRIPT_DIR}/select_version.sh)

# Check if a Python version was selected
if [[ -n "$SELECTED_PYTHON" ]]; then
    CMD=$SELECTED_PYTHON
    # Can continue processing the selected Python version here
else
    CMD="python3"
fi

echo "Creating virtual environment '$VIRTUAL_ENV_NAME'..."
# Create the virtual environment
$CMD -m venv ${VENV_STORAGE_DIR}/$VIRTUAL_ENV_NAME
if [ $? -ne 0 ]; then
    echo "Error: Failed to create virtual environment '$VIRTUAL_ENV_NAME'."
    exit 1
fi

echo "$DESCRIPTION" > "${VENV_STORAGE_DIR}/$VIRTUAL_ENV_NAME/description.txt"
if [ $? -ne 0 ]; then
    echo "Warning: Failed to write description to virtual environment."
fi

echo "Virtual environment '$VIRTUAL_ENV_NAME' created successfully."