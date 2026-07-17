#!/usr/bin/env bash
# penv upgrade — Self-update penv from the latest GitHub release

set -euo pipefail

SCRIPT_DIR=$(dirname "$(realpath "$0")")
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: penv upgrade"
    echo ""
    echo "Self-update penv from the latest GitHub release."
    echo ""
    echo "Detects installation type (git checkout, system"
    echo "package, or manual install) and updates accordingly."
    echo ""
    echo "Example:"
    echo "  penv upgrade"
    exit 0
fi

# ── Read current version ──
CURRENT_VERSION=""
if [[ -f "${PROJECT_ROOT}/VERSION" ]]; then
    CURRENT_VERSION=$(cat "${PROJECT_ROOT}/VERSION" | tr -d '[:space:]')
fi

if [[ -z "$CURRENT_VERSION" ]]; then
    die "Cannot determine current penv version."
fi

# ── Determine install type ──
INSTALL_TYPE="custom"
INSTALL_DIR="$PROJECT_ROOT"

# Check if running from /usr/local/penv (system install)
if [[ "$INSTALL_DIR" == "/usr/local/penv" ]]; then
    INSTALL_TYPE="system"
elif [[ -d "${INSTALL_DIR}/.git" ]]; then
    INSTALL_TYPE="git"
fi

REPO="quintin-lee/penv"

echo "penv upgrade — Checking for updates..."
echo "  Current version: ${CURRENT_VERSION}"
echo "  Install type:    ${INSTALL_TYPE}"
echo "  Install path:    ${INSTALL_DIR}"
echo ""

# ── Detect sudo ──
SUDO_CMD=""
if [[ "$INSTALL_TYPE" == "system" ]]; then
    if [[ ! -w "$INSTALL_DIR" ]]; then
        if command -v sudo &>/dev/null; then
            SUDO_CMD="sudo"
        else
            die "System install at ${INSTALL_DIR} requires write access or sudo."
        fi
    fi
fi

# ── Check for curl ──
if ! command -v curl &>/dev/null; then
    die "curl is required for upgrade. Install curl and try again."
fi

# ── Fetch latest release from GitHub API ──
echo "  Fetching latest release info from GitHub..."
LATEST_TAG=""

# Use /repos/.../releases/latest (redirects to latest, but API always returns last non-prerelease)
GITHUB_OUTPUT=$(curl -sfL --connect-timeout 10 "https://api.github.com/repos/${REPO}/releases/latest" 2>/dev/null || true)

if [[ -z "$GITHUB_OUTPUT" ]]; then
    # Try alternative: get from git tag via GitHub API
    echo "  Warning: Could not fetch release info. GitHub API may be rate-limited."
    echo ""
    echo "  You can manually upgrade by downloading the latest release from:"
    echo "  https://github.com/${REPO}/releases/latest"
    exit 1
fi

LATEST_TAG=$(echo "$GITHUB_OUTPUT" | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4)

if [[ -z "$LATEST_TAG" ]]; then
    die "Could not parse latest release tag from GitHub API response."
fi

# Strip leading 'v' for version comparison
LATEST_VERSION="${LATEST_TAG#v}"

echo "  Latest version:  ${LATEST_VERSION} (tag: ${LATEST_TAG})"
echo ""

# ── Compare versions ──
if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
    echo "Already up to date (${CURRENT_VERSION})."
    exit 0
fi

echo "A new version is available: ${CURRENT_VERSION} → ${LATEST_VERSION}"
echo ""

# ── Confirm ──
echo -n "Upgrade penv to ${LATEST_VERSION}? [y/N] "
read -r CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Upgrade cancelled."
    exit 1
fi

# ── Download archive ──
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

ARCHIVE_URL="https://github.com/${REPO}/archive/refs/tags/${LATEST_TAG}.tar.gz"
echo "  Downloading ${LATEST_TAG}..."
if ! curl -fL --connect-timeout 15 --progress-bar "$ARCHIVE_URL" -o "${TEMP_DIR}/penv.tar.gz" 2>/dev/null; then
    die "Download failed."
fi

# ── Extract ──
echo "  Extracting..."
if ! tar -xzf "${TEMP_DIR}/penv.tar.gz" -C "$TEMP_DIR" 2>/dev/null; then
    die "Extraction failed. Downloaded file may be corrupted."
fi

# Find extracted directory (github archive names are repo-tag)
EXTRACTED_DIR=""
for d in "${TEMP_DIR}"/*/; do
    if [[ -f "${d}/penv" ]]; then
        EXTRACTED_DIR="$d"
        break
    fi
done

if [[ -z "$EXTRACTED_DIR" ]]; then
    die "Extracted archive does not contain penv."
fi

# ── Verify extracted version matches ──
EXTRACTED_VERSION=$(cat "${EXTRACTED_DIR}/VERSION" 2>/dev/null | tr -d '[:space:]' || echo "")
if [[ "$EXTRACTED_VERSION" != "$LATEST_VERSION" ]]; then
    echo "  Warning: Extracted version (${EXTRACTED_VERSION}) does not match expected (${LATEST_VERSION})."
    echo -n "Continue anyway? [y/N] "
    read -r CONFIRM2
    if [[ ! "$CONFIRM2" =~ ^[Yy]$ ]]; then
        echo "Upgrade cancelled."
        exit 1
    fi
fi

# ── Install ──
echo "  Installing..."

case "$INSTALL_TYPE" in
    git)
        # Git clone: just copy files (user will commit)
        $SUDO_CMD cp -r "${EXTRACTED_DIR}"/* "$INSTALL_DIR/" 2>/dev/null || {
            die "Failed to copy files to ${INSTALL_DIR}."
        }
        echo "  Updated files in ${INSTALL_DIR}."
        echo "  Note: You may want to review changes with 'git status'."
        ;;
    system|*)
        # System or custom install: recursive copy preserving structure
        $SUDO_CMD cp -r "${EXTRACTED_DIR}/penv" "${INSTALL_DIR}/"
        $SUDO_CMD cp -r "${EXTRACTED_DIR}/scripts" "${INSTALL_DIR}/"
        $SUDO_CMD cp -r "${EXTRACTED_DIR}/tools" "${INSTALL_DIR}/" 2>/dev/null || true

        # Ensure files are executable
        $SUDO_CMD chmod +x "${INSTALL_DIR}/penv"
        $SUDO_CMD chmod +x "${INSTALL_DIR}/scripts/"*.sh
        $SUDO_CMD chmod +x "${INSTALL_DIR}/tools/"*.sh 2>/dev/null || true
        ;;
esac

# ── Update VERSION if needed ──
echo "$LATEST_VERSION" | $SUDO_CMD tee "${INSTALL_DIR}/VERSION" > /dev/null

echo ""
echo "√ penv upgraded from ${CURRENT_VERSION} to ${LATEST_VERSION}."
echo ""
echo "  Restart your shell or re-source your profile to use the new version."
echo "  Run 'penv --version' to verify."
