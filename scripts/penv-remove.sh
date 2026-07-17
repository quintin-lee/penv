#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "${SCRIPT_DIR}/env.sh"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: penv remove <env_name> [env_name2 ...]"
    echo ""
    echo "Remove one or more virtual environments."
    echo ""
    echo "If no name is given and fzf is installed, an interactive"
    echo "multi-select picker is shown."
    echo ""
    echo "Examples:"
    echo "  penv remove myproject"
    echo "  penv remove oldproject myproject testproject"
    exit 0
fi

# Helper: remove a single validated environment
_remove_one() {
    local env_name="$1"
    if [[ ! "$env_name" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        echo "Error: Invalid environment name '$env_name'. Skipping." >&2
        return 1
    fi
    if [[ ! -d "${VENV_STORAGE_DIR}/${env_name}" ]]; then
        echo "Error: Environment '$env_name' does not exist. Skipping." >&2
        return 1
    fi
    # Safety check
    if [[ "${VENV_STORAGE_DIR}" != *"/.cache/python-venv" && "${VENV_STORAGE_DIR}" != "$HOME"* && "${VENV_STORAGE_DIR}" != "/tmp/"* ]]; then
        echo "Error: Safety check failed. Skipping '$env_name'." >&2
        return 1
    fi
    echo "Removing virtual environment '$env_name'..."
    if rm -rf "${VENV_STORAGE_DIR:?}/${env_name:?}"; then
        echo "Virtual environment '$env_name' has been successfully deleted."
        # Clean up activation markers
        rm -f "${VENV_STORAGE_DIR}/${env_name}.activate" "${VENV_STORAGE_DIR}/${env_name}.pid"
        return 0
    else
        echo "Error: Failed to delete '$env_name'." >&2
        return 1
    fi
}

# Interactive fzf multi-select when no argument given
if [[ $# -eq 0 ]]; then
    if command -v fzf &>/dev/null; then
        envs=()
        for env_path in "${VENV_STORAGE_DIR}"/*/; do
            [[ -d "$env_path" ]] || continue
            envs+=("$(basename "$env_path")")
        done
        if [[ ${#envs[@]} -eq 0 ]]; then
            die "No virtual environments found."
        fi
        selected=$(printf "%s\n" "${envs[@]}" | fzf --multi --prompt="Select environments to remove (Tab to multi-select) > ")
        [[ -z "$selected" ]] && exit 0

        echo "Selected environment(s):"
        echo "$selected"
        echo ""
        echo -n "Remove these environment(s)? [y/N] "
        read -r CONFIRM
        if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 1
        fi

        while IFS= read -r env; do
            [[ -z "$env" ]] && continue
            _remove_one "$env"
        done <<< "$selected"
        exit 0
    else
        die "Please specify the virtual environment to remove."
        echo "Usage: penv remove <virtual_env_name>"
    fi
fi

VIRTUAL_ENV_NAME=$1

# Validate virtual environment name (no special characters except - and _)
if [[ ! "$VIRTUAL_ENV_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    die "Invalid virtual environment name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
fi

# Check if virtual environment exists and remove it
if [ -d "${VENV_STORAGE_DIR}/$VIRTUAL_ENV_NAME" ]
then
    # Additional safety check to ensure we're only removing legitimate venv directories
    if [[ "${VENV_STORAGE_DIR}" == *"/.cache/python-venv" || "${VENV_STORAGE_DIR}" == "$HOME"* || "${VENV_STORAGE_DIR}" == "/tmp/"* ]]; then
        echo "Removing virtual environment '$VIRTUAL_ENV_NAME'..."
        if rm -rf "${VENV_STORAGE_DIR:?}/${VIRTUAL_ENV_NAME:?}"; then
            echo "Virtual environment '$VIRTUAL_ENV_NAME' has been successfully deleted."
            # Clean up activation markers
            rm -f "${VENV_STORAGE_DIR}/${VIRTUAL_ENV_NAME}.activate" "${VENV_STORAGE_DIR}/${VIRTUAL_ENV_NAME}.pid"
        else
            die "Failed to delete virtual environment '$VIRTUAL_ENV_NAME'."
        fi
    else
        die "Safety check failed. VENV_STORAGE_DIR appears to be misconfigured."
    fi
else
    die "Virtual environment '$VIRTUAL_ENV_NAME' does not exist."
fi