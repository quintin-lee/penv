#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "${SCRIPT_DIR}/env.sh"

# Check arguments
if [ $# -lt 2 ]
then
    echo "Error: Please specify the source and destination virtual environment names."
    echo "Usage: penv clone <source_env_name> <dest_env_name> [description]"
    echo "  source_env_name: Name of the environment to clone from"
    echo "  dest_env_name: Name of the new environment to create"
    echo "  description: Optional description for the new environment"
    exit 1
fi

SOURCE_ENV_NAME=$1
DEST_ENV_NAME=$2
DESCRIPTION="${3:-Cloned from $SOURCE_ENV_NAME}"

# Validate environment names
if [[ ! "$SOURCE_ENV_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "Error: Invalid source environment name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
    exit 1
fi

if [[ ! "$DEST_ENV_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "Error: Invalid destination environment name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
    exit 1
fi

# Check if source environment exists
if [ ! -d "${VENV_STORAGE_DIR}/$SOURCE_ENV_NAME" ]
then
    echo "Error: Source virtual environment '$SOURCE_ENV_NAME' does not exist."
    exit 1
fi

# Check if destination environment already exists
if [ -d "${VENV_STORAGE_DIR}/$DEST_ENV_NAME" ]
then
    echo "Error: Destination virtual environment '$DEST_ENV_NAME' already exists."
    exit 1
fi

# Check if source Python executable exists
SOURCE_PYTHON="${VENV_STORAGE_DIR}/${SOURCE_ENV_NAME}/bin/python"
if [ ! -f "$SOURCE_PYTHON" ]
then
    echo "Error: Python executable not found in source environment '$SOURCE_ENV_NAME'."
    exit 1
fi

echo "Cloning virtual environment '$SOURCE_ENV_NAME' to '$DEST_ENV_NAME'..."

# Create destination directory
if ! cp -r "${VENV_STORAGE_DIR}/$SOURCE_ENV_NAME" "${VENV_STORAGE_DIR}/$DEST_ENV_NAME"; then
    echo "Error: Failed to clone environment."
    exit 1
fi

# Fix any paths that may be hardcoded in the cloned environment
# This is important for making sure the Python interpreter uses the correct paths
find "${VENV_STORAGE_DIR}/$DEST_ENV_NAME/bin" -type f -exec sed -i "s|${VENV_STORAGE_DIR}/$SOURCE_ENV_NAME|${VENV_STORAGE_DIR}/$DEST_ENV_NAME|g" {} \; 2>/dev/null || true

# Create the description file
if ! printf "%s\n" "$DESCRIPTION" > "${VENV_STORAGE_DIR}/$DEST_ENV_NAME/description.txt"; then
    echo "Warning: Failed to write description to virtual environment."
fi

echo "Virtual environment '$DEST_ENV_NAME' cloned successfully from '$SOURCE_ENV_NAME'."