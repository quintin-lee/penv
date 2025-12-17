#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "${SCRIPT_DIR}/env.sh"

# Check arguments
if [ $# -lt 1 ]
then
    echo "Error: Please specify an operation."
    echo "Usage: penv project <bind|unbind|show|list>"
    echo "  bind: Bind current directory to a virtual environment"
    echo "  unbind: Remove binding for current directory"
    echo "  show: Show current directory binding"
    echo "  list: List all project bindings"
    exit 1
fi

OPERATION=$1
CURRENT_DIR=$(pwd)

case "$OPERATION" in
    bind)
        if [ $# -lt 2 ]; then
            echo "Error: Please specify the virtual environment name to bind."
            echo "Usage: penv project bind <env_name>"
            exit 1
        fi
        
        VIRTUAL_ENV_NAME=$2
        
        # Validate environment name
        if [[ ! "$VIRTUAL_ENV_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
            echo "Error: Invalid virtual environment name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
            exit 1
        fi
        
        # Check if environment exists
        if [ ! -d "${VENV_STORAGE_DIR}/$VIRTUAL_ENV_NAME" ]; then
            echo "Error: Virtual environment '$VIRTUAL_ENV_NAME' does not exist."
            exit 1
        fi

        # Create .penv file in current directory
        if echo "$VIRTUAL_ENV_NAME" > .penv; then
            echo "Successfully bound current directory to virtual environment '$VIRTUAL_ENV_NAME'."
        else
            echo "Error: Failed to create .penv file in current directory."
            exit 1
        fi
        ;;
    unbind)
        if [ -f .penv ]; then
            BOUND_ENV=$(cat .penv)
            rm .penv
            echo "Successfully unbound current directory from virtual environment '$BOUND_ENV'."
        else
            echo "No binding found in current directory."
        fi
        ;;
    show)
        if [ -f .penv ]; then
            BOUND_ENV=$(cat .penv)
            echo "Current directory is bound to virtual environment: $BOUND_ENV"
            
            # Check if the environment exists
            if [ ! -d "${VENV_STORAGE_DIR}/$BOUND_ENV" ]; then
                echo "Warning: Bound environment '$BOUND_ENV' does not exist."
            fi
        else
            echo "Current directory is not bound to any virtual environment."
        fi
        ;;
    list)
        echo "Searching for project bindings..."
        # Find all .penv files in subdirectories
        if find "${HOME}" -name ".penv" -type f 2>/dev/null | grep . > /dev/null; then
            find "${HOME}" -name ".penv" -type f 2>/dev/null | while read -r penv_file; do
                project_dir=$(dirname "$penv_file")
                env_name=$(cat "$penv_file")
                echo "$project_dir -> $env_name"
            done
        else
            echo "No project bindings found."
        fi
        ;;
    *)
        echo "Error: Invalid operation. Use 'bind', 'unbind', 'show', or 'list'."
        exit 1
        ;;
esac