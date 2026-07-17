#!/usr/bin/env bash
# penv export — Archive a virtual environment as a tarball

SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "${SCRIPT_DIR}/env.sh"

if [[ $# -lt 1 ]]; then
    die "Usage: penv export <env_name> [output_file]"
fi

ENV_NAME="$1"
OUTPUT_FILE="${2:-${ENV_NAME}.tar.gz}"

# Validate name
if [[ ! "$ENV_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    die "Invalid environment name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
fi

ENV_DIR="${VENV_STORAGE_DIR}/${ENV_NAME}"
if [[ ! -d "$ENV_DIR" ]]; then
    die "Environment '$ENV_NAME' does not exist."
fi

# Create tarball with metadata
ARCHIVE_SCRIPT_DIR=$(dirname "$(realpath "$0")")
PROJECT_ROOT=$(dirname "$ARCHIVE_SCRIPT_DIR")

# Create metadata file in a temp location
METADATA_DIR=$(mktemp -d)
trap 'rm -rf "$METADATA_DIR"' EXIT

METADATA_FILE="${METADATA_DIR}/PENV_META"
{
    echo "penv_version=$(cat "${PROJECT_ROOT}/VERSION" 2>/dev/null || echo "unknown")"
    echo "env_name=${ENV_NAME}"
    echo "export_date=$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
    echo "python_version=$("${ENV_DIR}/bin/python" --version 2>&1 | cut -d' ' -f2 || echo "unknown")"
} > "$METADATA_FILE"

echo "Exporting environment '${ENV_NAME}' to '${OUTPUT_FILE}'..."

# Create archive in current directory (resolve relative paths)
OUTPUT_ABS=$(mkdir -p "$(dirname "$OUTPUT_FILE")" && realpath "$(dirname "$OUTPUT_FILE")")/$(basename "$OUTPUT_FILE")

# Build components: env dir + metadata
BUILD_DIR=$(mktemp -d)
trap 'rm -rf "$METADATA_DIR" "$BUILD_DIR"' EXIT

# Copy the environment to a staging dir with a consistent name
STAGING_DIR="${BUILD_DIR}/${ENV_NAME}"
cp -r "$ENV_DIR" "$STAGING_DIR"
cp "$METADATA_FILE" "${BUILD_DIR}/PENV_META"

# Create tarball
(cd "$BUILD_DIR" && tar -czf "$OUTPUT_ABS" "$ENV_NAME" PENV_META) || {
    die "Failed to create archive."
}

# Verify archive integrity
tar -tzf "$OUTPUT_ABS" > /dev/null 2>&1 || {
    rm -f "$OUTPUT_ABS"
    die "Archive verification failed. Aborted."
}

SIZE=$(du -h "$OUTPUT_ABS" 2>/dev/null | cut -f1 || echo "?")
echo "Exported successfully: ${OUTPUT_ABS} (${SIZE})"
echo ""
echo "To import on another machine:"
echo "  penv import \"${OUTPUT_ABS##*/}\""
