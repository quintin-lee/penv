#!/usr/bin/env bash
#
# make_tag.sh — Create a git tag from the VERSION file
#
# This is the single entry point for creating release tags.
# The VERSION file is the single source of truth — the tag
# name is derived from it automatically.
#
# Usage: ./tools/make_tag.sh [--dry-run]
#
# Options:
#   --dry-run   Print what would be done without doing it

set -euo pipefail

# Unified error handler
die() {
    echo "ERROR: $*" >&2
    exit 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$SCRIPT_DIR/VERSION"
PKGBUILD_FILE="$SCRIPT_DIR/PKGBUILD"
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

# ── 1. Read version ──────────────────────────────────────────

if [[ ! -f "$VERSION_FILE" ]]; then
    die "VERSION file not found at $VERSION_FILE"
fi

VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"

if [[ -z "$VERSION" ]]; then
    die "VERSION file is empty"
fi

# Validate semver-ish format (X.Y.Z or X.Y)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
    die "'$VERSION' is not a valid version number (expected X.Y.Z or X.Y)"
fi

TAG="v$VERSION"

echo "==> VERSION file: $VERSION"
echo "==> Tag to create: $TAG"
echo ""

# ── 2. Check git state ──────────────────────────────────────

cd "$SCRIPT_DIR"

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    die "Not inside a git repository"
fi

if [[ -n "$(git status --porcelain)" ]]; then
    echo "WARNING: You have uncommitted changes:"
    git status --short
    echo ""
    echo "It is recommended to commit all changes before tagging."
    echo -n "Proceed anyway? [y/N] "
    read -r CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# ── 3. Check for existing tag ───────────────────────────────

if git tag -l | grep -qxF "$TAG"; then
    echo "ERROR: Tag '$TAG' already exists:"
    git log --oneline -1 "$TAG" 2>/dev/null || true
    echo ""
    echo -n "Delete existing tag and recreate? [y/N] "
    read -r CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        if $DRY_RUN; then
            echo "  (dry-run) git tag -d $TAG"
        else
            git tag -d "$TAG"
            echo "Deleted tag '$TAG' locally."
        fi
    else
        echo "Aborted."
        exit 1
    fi
fi

# ── 4. Sync PKGBUILD pkgver if needed ───────────────────────

if [[ -f "$PKGBUILD_FILE" ]]; then
    CURRENT_PKGVER="$(grep -E '^pkgver=' "$PKGBUILD_FILE" | sed 's/^pkgver=//' | tr -d '"')"
    if [[ "$CURRENT_PKGVER" != "$VERSION" ]]; then
        echo "NOTE: PKGBUILD pkgver=$CURRENT_PKGVER, VERSION=$VERSION"
        echo -n "Update PKGBUILD pkgver to $VERSION? [Y/n] "
        read -r CONFIRM
        if [[ -z "$CONFIRM" || "$CONFIRM" =~ ^[Yy]$ ]]; then
            if $DRY_RUN; then
                echo "  (dry-run) sed -i 's/^pkgver=.*/pkgver=$VERSION/' PKGBUILD"
            else
                if [[ "$(uname -s)" == "Darwin" ]]; then
                    sed -i '' "s/^pkgver=.*/pkgver=\"$VERSION\"/" "$PKGBUILD_FILE"
                else
                    sed -i "s/^pkgver=.*/pkgver=\"$VERSION\"/" "$PKGBUILD_FILE"
                fi
                echo "Updated PKGBUILD pkgver -> $VERSION."
            fi
        fi
    else
        echo "OK: PKGBUILD pkgver is already $VERSION."
    fi
fi

echo ""

# ── 5. Summary and confirm ──────────────────────────────────

echo "========================================"
echo "  Tag:     $TAG"
echo "  Target:  $(git rev-parse --short HEAD) ($(git log -1 --pretty=%s HEAD))"
echo "  Dry-run: $DRY_RUN"
echo "========================================"
echo ""
echo -n "Create tag '$TAG'? [y/N] "
read -r CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# ── 6. Create tag ───────────────────────────────────────────

if $DRY_RUN; then
    echo "  (dry-run) git tag -a '$TAG' -m 'chore: release v$VERSION'"
    echo "Done (dry-run)."
else
    git tag -a "$TAG" -m "chore: release v$VERSION"
    echo "Created tag '$TAG'."
    echo ""
    echo "To push it:"
    echo "  git push origin $TAG"
    echo ""
    echo "To remove it:"
    echo "  git tag -d $TAG"
fi
