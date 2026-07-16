#!/usr/bin/env bash
# penv info — Show detailed information about a virtual environment

SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "${SCRIPT_DIR}/env.sh"

if [[ $# -eq 0 ]]; then
    die "Please specify the virtual environment name."
    echo "Usage: penv info <env_name>"
fi

ENV_NAME=$1

# Validate name
if [[ ! "$ENV_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    die "Invalid virtual environment name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
fi

ENV_DIR="${VENV_STORAGE_DIR}/${ENV_NAME}"

if [[ ! -d "$ENV_DIR" ]]; then
    die "Virtual environment '$ENV_NAME' does not exist."
fi

# --- Collect info ---

# Description
DESCRIPTION_FILE="${ENV_DIR}/description.txt"
if [[ -f "$DESCRIPTION_FILE" ]]; then
    DESCRIPTION=$(cat "$DESCRIPTION_FILE" 2>/dev/null || true)
else
    DESCRIPTION=""
fi

# Python version
PYTHON_BIN="${ENV_DIR}/bin/python"
if [[ -x "$PYTHON_BIN" ]]; then
    PYTHON_VERSION=$(timeout 5s "$PYTHON_BIN" --version 2>/dev/null | cut -d' ' -f2)
    [[ -z "$PYTHON_VERSION" ]] && PYTHON_VERSION="Unknown"
else
    PYTHON_VERSION="(not found)"
fi

# Disk usage
DISK_USAGE=$(du -sh "$ENV_DIR" 2>/dev/null | cut -f1)
[[ -z "$DISK_USAGE" ]] && DISK_USAGE="Unknown"

# Package count
PACKAGE_COUNT=$("$PYTHON_BIN" -m pip list --format=columns 2>/dev/null | tail -n +3 | wc -l 2>/dev/null || true)
[[ -z "$PACKAGE_COUNT" ]] && PACKAGE_COUNT="?"

# Creation time
if [[ "$(uname -s)" == "Darwin" ]]; then
    CREATED=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$ENV_DIR" 2>/dev/null || echo "Unknown")
else
    CREATED=$(stat -c "%Y" "$ENV_DIR" 2>/dev/null || echo "0")
    if [[ "$CREATED" != "0" ]]; then
        CREATED=$(date -d "@$CREATED" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "Unknown")
    else
        CREATED="Unknown"
    fi
fi

# Activation status
ACTIVATED=false
if [[ -f "${VENV_STORAGE_DIR}/${ENV_NAME}.activate" ]]; then
    ACTIVATED=true
fi

# Activation count
if $ACTIVATED; then
    ACTIVATION_COUNT=$(cat "${VENV_STORAGE_DIR}/${ENV_NAME}.activate" 2>/dev/null || echo "?")
else
    ACTIVATION_COUNT="0"
fi

# Requirements file
REQUIREMENTS_FILE="${ENV_DIR}/requirements.txt"
if [[ -f "$REQUIREMENTS_FILE" ]]; then
    REQ_COUNT=$(wc -l < "$REQUIREMENTS_FILE" 2>/dev/null || true)
    REQ_INFO="${REQUIREMENTS_FILE} (${REQ_COUNT} entries)"
else
    REQ_INFO="(not found)"
fi

# Python executable path
PYTHON_PATH=$(readlink -f "$PYTHON_BIN" 2>/dev/null || echo "$PYTHON_BIN")
PYTHON_PATH_RESOLVED=""
if [[ "$PYTHON_PATH" != "$PYTHON_BIN" ]]; then
    PYTHON_PATH_RESOLVED=" -> ${PYTHON_PATH}"
fi

# --- Output ---
echo "Name:           ${ENV_NAME}"
if [[ -n "$DESCRIPTION" ]]; then
    echo "Description:    ${DESCRIPTION}"
fi
echo "Python:         ${PYTHON_VERSION}"
echo "Python Path:    ${PYTHON_BIN}${PYTHON_PATH_RESOLVED}"
echo "Path:           ${ENV_DIR}"
echo "Disk Usage:     ${DISK_USAGE}"
echo "Packages:       ${PACKAGE_COUNT}"
echo "Created:        ${CREATED}"
if $ACTIVATED; then
    echo "Activated:      yes (${ACTIVATION_COUNT} session(s))"
else
    echo "Activated:      no"
fi
echo "Requirements:   ${REQ_INFO}"
