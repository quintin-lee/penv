#!/usr/bin/env bash
# penv tree — Display package dependency tree for an environment

SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "${SCRIPT_DIR}/env.sh"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: penv tree <env_name>"
    echo ""
    echo "Display package dependency tree for an environment."
    echo ""
    echo "Uses pipdeptree if available for a full tree,"
    echo "otherwise shows a flat list of installed packages."
    echo ""
    echo "Example:"
    echo "  penv tree myproject"
    exit 0
fi

if [[ $# -lt 1 ]]; then
    die "Usage: penv tree <env_name>"
fi

ENV_NAME="$1"

# Validate name
if [[ ! "$ENV_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    die "Invalid environment name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
fi

ENV_DIR="${VENV_STORAGE_DIR}/${ENV_NAME}"
if [[ ! -d "$ENV_DIR" ]]; then
    die "Environment '$ENV_NAME' does not exist."
fi

PYTHON_PATH="${ENV_DIR}/bin/python"
if [[ ! -f "$PYTHON_PATH" ]]; then
    die "Python executable not found in environment '$ENV_NAME'."
fi

# ── Get Python version ──
PYTHON_VER=$("$PYTHON_PATH" --version 2>&1 | cut -d' ' -f2)

# ── Get installed packages via pip ──
PACKAGE_JSON=$("$PYTHON_PATH" -m pip list --format=json 2>/dev/null || true)
if [[ -z "$PACKAGE_JSON" || "$PACKAGE_JSON" == "[]" ]]; then
    echo "${ENV_NAME} (Python ${PYTHON_VER})"
    echo ""
    echo "  No packages installed."
    exit 0
fi

# ── Detect pipdeptree ──
HAS_PIPDEPTREE=false
if "$PYTHON_PATH" -m pipdeptree --version &>/dev/null; then
    HAS_PIPDEPTREE=true
fi

# ── Render ──
echo "${ENV_NAME} (Python ${PYTHON_VER})"
echo ""

if $HAS_PIPDEPTREE; then
    # Use pipdeptree for rich dependency tree
    "$PYTHON_PATH" -m pipdeptree 2>/dev/null || {
        # Fallback on failure
        HAS_PIPDEPTREE=false
    }
fi

if ! $HAS_PIPDEPTREE; then
    # Flat alphabetical list as fallback
    echo "$PACKAGE_JSON" | "$PYTHON_PATH" -c "
import json, sys
data = json.load(sys.stdin)
pkgs = sorted([(p['name'], p['version']) for p in data], key=lambda x: x[0].lower())
count = len(pkgs)
print(f'  Installed packages ({count}):')
for name, ver in pkgs:
    print(f'    {name} {ver}')
" 2>/dev/null || {
        # Absolute fallback: raw pip list
        echo "  Installed packages:"
        "$PYTHON_PATH" -m pip list --format=columns 2>/dev/null | tail -n +3 || echo "    (unable to list packages)"
    }
fi
