#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "${SCRIPT_DIR}/env.sh"

# Check arguments
if [ $# -lt 2 ]
then
    die "Please specify the virtual environment and operation (export/import)."
    echo "Usage: penv requirements <env_name> <export|import> [requirements_file]"
    echo "  export: Export environment packages to requirements.txt"
    echo "  import: Import packages from requirements.txt to environment"
fi

VIRTUAL_ENV_NAME=$1
OPERATION=$2
REQUIREMENTS_FILE=${3:-"${VENV_STORAGE_DIR}/${VIRTUAL_ENV_NAME}/requirements.txt"}

# Validate virtual environment name
if [[ ! "$VIRTUAL_ENV_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    die "Invalid virtual environment name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
fi

# Check if virtual environment exists
if [ ! -d "${VENV_STORAGE_DIR}/$VIRTUAL_ENV_NAME" ]
then
    die "Virtual environment '$VIRTUAL_ENV_NAME' does not exist."
fi

# Get the Python executable path for the environment
PYTHON_PATH="${VENV_STORAGE_DIR}/${VIRTUAL_ENV_NAME}/bin/python"
if [ ! -f "$PYTHON_PATH" ]
then
    die "Python executable not found in environment '$VIRTUAL_ENV_NAME'."
fi

case "$OPERATION" in
    export)
        echo "Exporting requirements from virtual environment '$VIRTUAL_ENV_NAME' to '$REQUIREMENTS_FILE'..."
        if "$PYTHON_PATH" -m pip freeze > "$REQUIREMENTS_FILE"; then
            echo "Requirements exported successfully to '$REQUIREMENTS_FILE'."
        else
            die "Failed to export requirements. Make sure pip is available in the environment."
        fi
        ;;
    import)
        if [ ! -f "$REQUIREMENTS_FILE" ]; then
            die "Requirements file '$REQUIREMENTS_FILE' does not exist."
        fi
        echo "Installing requirements from '$REQUIREMENTS_FILE' to virtual environment '$VIRTUAL_ENV_NAME'..."
        if "$PYTHON_PATH" -m pip install -r "$REQUIREMENTS_FILE"; then
            echo "Requirements installed successfully."
        else
            die "Failed to install requirements from '$REQUIREMENTS_FILE'."
        fi
        ;;
    *)
        die "Invalid operation. Use 'export' or 'import'."
        ;;
esac