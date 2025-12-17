#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "${SCRIPT_DIR}/env.sh"

# Check arguments
if [ $# -lt 2 ]
then
    echo "Error: Please specify the virtual environment and operation (export/import)."
    echo "Usage: penv requirements <env_name> <export|import> [requirements_file]"
    echo "  export: Export environment packages to requirements.txt"
    echo "  import: Import packages from requirements.txt to environment"
    exit 1
fi

VIRTUAL_ENV_NAME=$1
OPERATION=$2
REQUIREMENTS_FILE=${3:-"${VENV_STORAGE_DIR}/${VIRTUAL_ENV_NAME}/requirements.txt"}

# Validate virtual environment name
if [[ ! "$VIRTUAL_ENV_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "Error: Invalid virtual environment name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
    exit 1
fi

# Check if virtual environment exists
if [ ! -d "${VENV_STORAGE_DIR}/$VIRTUAL_ENV_NAME" ]
then
    echo "Error: Virtual environment '$VIRTUAL_ENV_NAME' does not exist."
    exit 1
fi

# Get the Python executable path for the environment
PYTHON_PATH="${VENV_STORAGE_DIR}/${VIRTUAL_ENV_NAME}/bin/python"
if [ ! -f "$PYTHON_PATH" ]
then
    echo "Error: Python executable not found in environment '$VIRTUAL_ENV_NAME'."
    exit 1
fi

case "$OPERATION" in
    export)
        echo "Exporting requirements from virtual environment '$VIRTUAL_ENV_NAME' to '$REQUIREMENTS_FILE'..."
        if "$PYTHON_PATH" -m pip freeze > "$REQUIREMENTS_FILE" 2>/dev/null; then
            echo "Requirements exported successfully to '$REQUIREMENTS_FILE'."
        else
            echo "Error: Failed to export requirements. Make sure pip is available in the environment."
            exit 1
        fi
        ;;
    import)
        if [ ! -f "$REQUIREMENTS_FILE" ]; then
            echo "Error: Requirements file '$REQUIREMENTS_FILE' does not exist."
            exit 1
        fi
        echo "Installing requirements from '$REQUIREMENTS_FILE' to virtual environment '$VIRTUAL_ENV_NAME'..."
        if "$PYTHON_PATH" -m pip install -r "$REQUIREMENTS_FILE" 2>/dev/null; then
            echo "Requirements installed successfully."
        else
            echo "Error: Failed to install requirements from '$REQUIREMENTS_FILE'."
            exit 1
        fi
        ;;
    *)
        echo "Error: Invalid operation. Use 'export' or 'import'."
        exit 1
        ;;
esac