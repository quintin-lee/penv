#!/usr/bin/env bash
# penv rename — Rename a virtual environment

SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "${SCRIPT_DIR}/env.sh"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: penv rename <old_name> <new_name>"
    echo ""
    echo "Rename a virtual environment."
    echo ""
    echo "This also updates activation markers and"
    echo "project bindings that reference the old name."
    echo ""
    echo "Example:"
    echo "  penv rename myproject myproject2"
    exit 0
fi

if [[ $# -lt 2 ]]; then
    die "Please specify the source and new names."
    echo "Usage: penv rename <old_name> <new_name>"
fi

OLD_NAME=$1
NEW_NAME=$2

# Validate names
if [[ ! "$OLD_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    die "Invalid source environment name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
fi
if [[ ! "$NEW_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    die "Invalid new environment name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
fi

OLD_DIR="${VENV_STORAGE_DIR}/${OLD_NAME}"
NEW_DIR="${VENV_STORAGE_DIR}/${NEW_NAME}"

# Check old env exists
if [[ ! -d "$OLD_DIR" ]]; then
    die "Virtual environment '$OLD_NAME' does not exist."
fi

# Check new env doesn't already exist
if [[ -d "$NEW_DIR" ]]; then
    die "Virtual environment '$NEW_NAME' already exists."
fi

echo "Renaming virtual environment '$OLD_NAME' to '$NEW_NAME'..."

# Move directory
if ! mv "$OLD_DIR" "$NEW_DIR"; then
    die "Failed to rename environment (mv failed)."
fi

# Fix hardcoded paths (same approach as clone.sh)
find "${NEW_DIR}/bin" -type f -exec sed -i "s|${VENV_STORAGE_DIR}/${OLD_NAME}|${VENV_STORAGE_DIR}/${NEW_NAME}|g" {} \; 2>/dev/null || true

# Rename activation marker if active
if [[ -f "${VENV_STORAGE_DIR}/${OLD_NAME}.activate" ]]; then
    mv "${VENV_STORAGE_DIR}/${OLD_NAME}.activate" "${VENV_STORAGE_DIR}/${NEW_NAME}.activate" 2>/dev/null || true
fi

# Rename PID file if exists
if [[ -f "${VENV_STORAGE_DIR}/${OLD_NAME}.pid" ]]; then
    mv "${VENV_STORAGE_DIR}/${OLD_NAME}.pid" "${VENV_STORAGE_DIR}/${NEW_NAME}.pid" 2>/dev/null || true
fi

echo "Virtual environment renamed to '$NEW_NAME' successfully."

# Update project bindings
if command -v grep &>/dev/null; then
    updated=0
    while IFS= read -r -d '' penv_file; do
        bound_env=$(cat "$penv_file" 2>/dev/null || true)
        if [[ "$bound_env" == "$OLD_NAME" ]]; then
            echo "$NEW_NAME" > "$penv_file" 2>/dev/null && ((updated++)) || true
        fi
    done < <(find "${HOME}" -maxdepth 5 -name ".penv" -type f -print0 2>/dev/null || true)
    if (( updated > 0 )); then
        echo "Updated ${updated} project binding(s) from '$OLD_NAME' to '$NEW_NAME'."
    fi
fi
