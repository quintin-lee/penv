#!/usr/bin/env bash
# penv import — Restore a virtual environment from a tarball

SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "${SCRIPT_DIR}/env.sh"

if [[ $# -lt 1 ]]; then
    die "Usage: penv import <archive> [new_name]"
fi

ARCHIVE="$1"
NEW_NAME="${2:-}"

# Validate archive exists
if [[ ! -f "$ARCHIVE" ]]; then
    die "Archive file '$ARCHIVE' not found."
fi

# Validate it's a gzipped tarball
if ! file "$ARCHIVE" 2>/dev/null | grep -qE 'gzip compressed|tar archive'; then
    die "File '$ARCHIVE' is not a valid gzip archive."
fi

# ── Extract to temp dir ──
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

if ! tar -xzf "$ARCHIVE" -C "$TEMP_DIR" 2>/dev/null; then
    die "Failed to extract archive. File may be corrupted."
fi

# ── Read metadata ──
ARCHIVE_ENV_NAME=""
PENV_VERSION=""

if [[ -f "${TEMP_DIR}/PENV_META" ]]; then
    while IFS='=' read -r key value; do
        case "$key" in
            env_name) ARCHIVE_ENV_NAME="$value" ;;
            penv_version) PENV_VERSION="$value" ;;
        esac
    done < "${TEMP_DIR}/PENV_META"
fi

# Determine the environment name
if [[ -z "$NEW_NAME" ]]; then
    if [[ -n "$ARCHIVE_ENV_NAME" ]]; then
        NEW_NAME="$ARCHIVE_ENV_NAME"
    else
        # Derive from archive filename: strip .tar.gz, .tgz, .tar
        NEW_NAME=$(basename "$ARCHIVE")
        NEW_NAME="${NEW_NAME%.tar.gz}"
        NEW_NAME="${NEW_NAME%.tgz}"
        NEW_NAME="${NEW_NAME%.tar}"
    fi
fi

if [[ -z "$NEW_NAME" ]]; then
    die "Could not determine environment name. Specify it: penv import <archive> <name>"
fi

# Validate name
if [[ ! "$NEW_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    die "Invalid environment name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
fi

# ── Find extracted env directory ──
EXTRACTED_ENV_DIR=""
for item in "${TEMP_DIR}"/*/; do
    item_name=$(basename "$item")
    if [[ "$item_name" != "PENV_META" && -d "${item}/bin" ]]; then
        EXTRACTED_ENV_DIR="$item"
        break
    fi
done

if [[ -z "$EXTRACTED_ENV_DIR" ]]; then
    die "No valid virtual environment found in the archive."
fi

# ── Check for name conflict ──
DEST_DIR="${VENV_STORAGE_DIR}/${NEW_NAME}"
if [[ -d "$DEST_DIR" ]]; then
    die "An environment named '$NEW_NAME' already exists."
fi

# ── Validate extracted env ──
if [[ ! -f "${EXTRACTED_ENV_DIR}/bin/python" && ! -f "${EXTRACTED_ENV_DIR}/bin/python3" ]]; then
    die "Extracted environment is missing Python interpreter."
fi
if [[ ! -f "${EXTRACTED_ENV_DIR}/pyvenv.cfg" ]]; then
    die "Extracted environment is missing pyvenv.cfg."
fi
if [[ ! -f "${EXTRACTED_ENV_DIR}/bin/activate" ]]; then
    die "Extracted environment is missing activate script."
fi

# ── Move to storage ──
echo "Importing environment as '${NEW_NAME}'..."

if ! mkdir -p "$VENV_STORAGE_DIR"; then
    die "Cannot access storage directory: $VENV_STORAGE_DIR"
fi

if ! mv "$EXTRACTED_ENV_DIR" "$DEST_DIR"; then
    die "Failed to move environment to storage directory."
fi

# ── Fix hardcoded paths in the new location ──
# Update pyvenv.cfg home
sed -i "s|^home = .*|home = $(dirname "$(readlink -f "${DEST_DIR}/bin/python" 2>/dev/null || echo "${DEST_DIR}/bin")")|" "${DEST_DIR}/pyvenv.cfg" 2>/dev/null || true

# Fix shebangs and paths in bin/
for f in "${DEST_DIR}/bin/"*; do
    [[ -f "$f" && ! -L "$f" ]] || continue
    sed -i "s|${EXTRACTED_ENV_DIR%/}|${DEST_DIR}|g" "$f" 2>/dev/null || true
done

SIZE=$(du -sh "$DEST_DIR" 2>/dev/null | cut -f1 || echo "?")
if [[ -n "$PENV_VERSION" ]]; then
    echo "Imported successfully: ${NEW_NAME} (${SIZE}, exported by penv ${PENV_VERSION})"
else
    echo "Imported successfully: ${NEW_NAME} (${SIZE})"
fi
