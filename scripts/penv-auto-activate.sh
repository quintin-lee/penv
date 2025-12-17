#!/usr/bin/env bash
# Auto-activation helper for shell profiles
# To use this, add the following to your ~/.bashrc or ~/.zshrc:
#
# source /path/to/penv/scripts/penv-auto-activate.sh
#

# Function to automatically activate environment bound to current directory
penv_auto_activate() {
    local SCRIPT_DIR=$(dirname "$(realpath "$0")")
    source "${SCRIPT_DIR}/env.sh" 2>/dev/null || source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

    # Check for .penv file in current directory
    if [ -f .penv ]; then
        local env_name=$(cat .penv)

        # Only activate if the environment exists
        if [ -d "$VENV_STORAGE_DIR/$env_name" ]; then
            # Check if the environment is already activated to avoid redundant activation
            if [ "$CURRENT_ENV" != "$env_name" ]; then
                echo "Auto-activating environment: $env_name"
                # Source the activation script directly
                if [ -f "$VENV_STORAGE_DIR/$env_name/bin/activate" ]; then
                    source "$VENV_STORAGE_DIR/$env_name/bin/activate"
                    # Create activation marker
                    echo "1" > "${VENV_STORAGE_DIR}/${env_name}.activate"
                    export CURRENT_ENV="$env_name"
                else
                    echo "Error: Activation script not found in environment $env_name"
                fi
            else
                echo "Environment $env_name is already active"
            fi
        else
            echo "Warning: Project is bound to environment '$env_name' but it doesn't exist."
        fi
    else
        echo "No environment binding found in current directory."
    fi
}

# Function to check for auto-activation when changing directories
_penv_cd_hook() {
    local target_dir="$1"
    # Call the actual cd command
    builtin cd "$target_dir" || return

    # Check if we're in a project directory with .penv file
    if [ -f .penv ]; then
        penv_auto_activate
    fi
}

# Optional: override the cd command to use our hook
# Uncomment the following line if you want auto-activation when using cd
# cd() {
#     _penv_cd_hook "$@"
# }