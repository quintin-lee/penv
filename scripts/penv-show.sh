#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "${SCRIPT_DIR}/env.sh"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: penv show"
    echo ""
    echo "Show currently active virtual environments."
    echo ""
    echo "Lists all environments with active markers"
    echo "and their usage count."
    echo ""
    echo "Example:"
    echo "  penv show"
    exit 0
fi

for f in "${VENV_STORAGE_DIR}"/*.activate
do
    # Skip if no matches found
    if [[ -f "$f" ]]; then
        FILENAME=$(basename "$f")
        ENV=$(echo "$FILENAME" | cut -d'.' -f1)
        echo "   *$ENV*"
    fi
done