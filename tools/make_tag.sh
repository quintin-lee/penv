#!/usr/bin/env bash
#
# make_tag.sh — Release automation: sync versions, commit, tag
#
# Interactive usage:
#   ./tools/make_tag.sh
#   Enter new version (current: 0.2.0): 0.3.0
#
# What it does:
#   1. Prompt for new version (updates VERSION file)
#   2. Syncs all static version references across codebase + docs
#   3. Transforms CHANGELOG: moves [Unreleased] into a versioned section
#   4. Stages + commits the version bump
#   5. Creates an annotated git tag v<VERSION>
#
# Usage: ./tools/make_tag.sh [--dry-run] [X.Y.Z]
#
# Options:
#   --dry-run   Print what would be done without making changes
#   X.Y.Z       Skip prompt, use this version directly

set -euo pipefail

die() { echo "ERROR: $*" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$SCRIPT_DIR/VERSION"
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

# ── 1. Read current version and prompt for new one ──────────

if [[ ! -f "$VERSION_FILE" ]]; then
    die "VERSION file not found at $VERSION_FILE"
fi

CURRENT_VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"

if [[ -z "$CURRENT_VERSION" ]]; then
    die "VERSION file is empty"
fi

# Parse arguments: support version X.Y.Z or --dry-run
if [[ "${1:-}" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
    NEW_VERSION="$1"
    if [[ "${2:-}" == "--dry-run" ]]; then
        DRY_RUN=true
    fi
elif [[ "$1" == "--dry-run" ]]; then
    echo "==> Current version: $CURRENT_VERSION"
    echo -n "==> Enter new version (or press Enter to keep $CURRENT_VERSION): "
    read -r NEW_VERSION
    NEW_VERSION="${NEW_VERSION:-$CURRENT_VERSION}"
elif [[ -n "${1:-}" ]]; then
    die "Usage: $0 [--dry-run] [X.Y.Z]"
else
    echo "==> Current version: $CURRENT_VERSION"
    echo -n "==> Enter new version (or press Enter to keep $CURRENT_VERSION): "
    read -r NEW_VERSION
    NEW_VERSION="${NEW_VERSION:-$CURRENT_VERSION}"
fi

# Validate semver (X.Y or X.Y.Z)
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
    die "'$NEW_VERSION' is not a valid version number (expected X.Y.Z or X.Y)"
fi

VERSION="$NEW_VERSION"

# Write to VERSION file if it changed
if [[ "$VERSION" != "$CURRENT_VERSION" ]]; then
    if $DRY_RUN; then
        echo "  (dry-run) VERSION: $CURRENT_VERSION -> $VERSION"
    else
        echo "$VERSION" > "$VERSION_FILE"
        echo "  VERSION: $CURRENT_VERSION -> $VERSION"
    fi
    UPDATED_FILES+=("VERSION")
else
    echo "  VERSION: $VERSION (unchanged)"
fi

TAG="v$VERSION"
echo "==> Tag:     $TAG"
echo ""

# ── 2. Sync static version references ───────────────────────

echo "--- Syncing version references ---"

UPDATED_FILES=()

# File list: path → sed expression (captures current version to replace)
declare -A SYNC
# shellcheck disable=SC2016
SYNC=(
    ["penv"]='s/^    VERSION="[0-9.]*"$/    VERSION="'$VERSION'"/'
    ["PKGBUILD"]='s/^pkgver="[0-9.]*"$/pkgver="'$VERSION'"/'
    ["Makefile"]='s/^VERSION ?= [0-9.]*$/VERSION ?= '"$VERSION"'/'
    ["tools/make_deb.sh"]='s/|| echo "[0-9.]*"$/|| echo "'$VERSION'"/'
)

for FILE in "${!SYNC[@]}"; do
    FILE_PATH="$SCRIPT_DIR/$FILE"
    if [[ ! -f "$FILE_PATH" ]]; then
        echo "  SKIP: $FILE (not found)"
        continue
    fi

    PATTERN="${SYNC[$FILE]}"

    # Check if file already has the correct version
    # (run sed and see if anything changed)
    NEW_CONTENT=$(sed "$PATTERN" "$FILE_PATH" 2>/dev/null)

    if [[ "$NEW_CONTENT" == "$(cat "$FILE_PATH")" ]]; then
        echo "  OK:   $FILE (already $VERSION)"
    else
        if $DRY_RUN; then
            echo "  NEED: $FILE (would update to $VERSION)"
        else
            # Use platform-safe sed
            if [[ "$(uname -s)" == "Darwin" ]]; then
                sed -i '' "$PATTERN" "$FILE_PATH"
            else
                sed -i "$PATTERN" "$FILE_PATH"
            fi
            echo "  DONE: $FILE -> $VERSION"
        fi
        UPDATED_FILES+=("$FILE")
    fi
done

# ── 3. Sync README badge (special case) ──────────────────────

README="$SCRIPT_DIR/README.md"
if [[ -f "$README" ]]; then
    # Extract current version from badge URL
    CURRENT_BADGE_VER=$(sed -n 's/.*version-\([0-9.]*\)-blue.*/\1/p' "$README" | head -1)
    if [[ -n "$CURRENT_BADGE_VER" && "$CURRENT_BADGE_VER" != "$VERSION" ]]; then
        if $DRY_RUN; then
            echo "  NEED: README.md badge ($CURRENT_BADGE_VER -> $VERSION)"
        else
            if [[ "$(uname -s)" == "Darwin" ]]; then
                sed -i '' "s/version-[0-9.]*-blue/version-$VERSION-blue/" "$README"
            else
                sed -i "s/version-[0-9.]*-blue/version-$VERSION-blue/" "$README"
            fi
            echo "  DONE: README.md badge -> $VERSION"
        fi
        UPDATED_FILES+=("README.md")
    else
        echo "  OK:   README.md badge (already $VERSION)"
    fi
fi

# ── 4. Sync CHANGELOG (special case) ─────────────────────────

CHANGELOG="$SCRIPT_DIR/CHANGELOG.md"
RELEASE_DATE=$(date +%F)

if [[ -f "$CHANGELOG" ]]; then
    # Find the [Unreleased] section
    UNRELEASED_LINE=$(grep -n '^## \[Unreleased\]' "$CHANGELOG" | head -1 | cut -d: -f1)

    if [[ -n "$UNRELEASED_LINE" ]]; then
        # Find the next version header after [Unreleased]
        NEXT_HEADER_LINE=$(tail -n +"$((UNRELEASED_LINE + 1))" "$CHANGELOG" | grep -n '^## \[' | head -1 | cut -d: -f1)

        if [[ -z "$NEXT_HEADER_LINE" ]]; then
            # No next header found (last section in file)
            NEXT_HEADER_LINE=$(wc -l < "$CHANGELOG")
        fi

        # Content exists if there are non-blank lines between Unreleased and next header
        CONTENT_LINES=$((NEXT_HEADER_LINE - UNRELEASED_LINE - 1))
        HAS_CONTENT=false
        if (( CONTENT_LINES > 1 )); then
            HAS_CONTENT=true
        fi

        if $HAS_CONTENT; then
            # Preview the content being released
            RELEASED_CONTENT=$(head -n "$((UNRELEASED_LINE + NEXT_HEADER_LINE - 1))" "$CHANGELOG" | tail -n "$((NEXT_HEADER_LINE - 1))" | sed 's/^/  /')

            if $DRY_RUN; then
                echo "  NEED: CHANGELOG.md — would release $VERSION ($RELEASE_DATE)"
                echo "  Content preview:"
                echo "$RELEASED_CONTENT" | head -20
            else
                if [[ "$(uname -s)" == "Darwin" ]]; then
                    sed -i '' "s/^## \[Unreleased\]/## [Unreleased]\n\n## [$VERSION] - $RELEASE_DATE/" "$CHANGELOG"
                else
                    sed -i "s/^## \[Unreleased\]/## [Unreleased]\n\n## [$VERSION] - $RELEASE_DATE/" "$CHANGELOG"
                fi
                echo "  DONE: CHANGELOG.md — released $VERSION ($RELEASE_DATE)"
                echo "  Content preview:"
                echo "$RELEASED_CONTENT" | head -20
            fi
            UPDATED_FILES+=("CHANGELOG.md")
        else
            echo "  OK:   CHANGELOG.md (no unreleased changes, adding empty $VERSION section)"
            if ! $DRY_RUN; then
                if [[ "$(uname -s)" == "Darwin" ]]; then
                    sed -i '' "s/^## \[Unreleased\]/## [Unreleased]\n\n## [$VERSION] - $RELEASE_DATE/" "$CHANGELOG"
                else
                    sed -i "s/^## \[Unreleased\]/## [Unreleased]\n\n## [$VERSION] - $RELEASE_DATE/" "$CHANGELOG"
                fi
            fi
            UPDATED_FILES+=("CHANGELOG.md")
        fi
    else
        echo "  SKIP: CHANGELOG.md (no [Unreleased] section found)"
    fi
fi

echo ""

# ── 5. Check git state ──────────────────────────────────────

cd "$SCRIPT_DIR"

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    die "Not inside a git repository"
fi

# warn about unrelated dirty files
UNRELATED_DIRTY=false
while IFS= read -r line; do
    f="${line:3}"  # strip "M " or "?? " prefix
    skip=false
    for u in "${UPDATED_FILES[@]}"; do
        [[ "$f" == "$u" ]] && skip=true && break
    done
    $skip || { UNRELATED_DIRTY=true; break; }
done < <(git status --porcelain)

if $UNRELATED_DIRTY; then
    echo "WARNING: You have uncommitted changes outside version files:"
    git status --short
    echo ""
    echo -n "Proceed anyway? [y/N] "
    read -r CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# ── 6. Check for existing tag ───────────────────────────────

if git tag -l | grep -qxF "$TAG"; then
    echo "Tag '$TAG' already exists:"
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

# ── 7. Stage and commit version bump (if any updates) ───────

echo ""
echo "--- Version bump ---"

if [[ ${#UPDATED_FILES[@]} -gt 0 ]]; then
    if $DRY_RUN; then
        echo "  (dry-run) git add ${UPDATED_FILES[*]}"
        echo "  (dry-run) git commit -m \"chore: bump version to v$VERSION\""
    else
        git add "${UPDATED_FILES[@]}"
        git commit -m "chore: bump version to v$VERSION"
        echo "  Committed: chore: bump version to v$VERSION"
        echo "  Files: ${UPDATED_FILES[*]}"
    fi
else
    echo "  No version files needed updating."
fi

echo ""

# ── 8. Summary and confirm tag ──────────────────────────────

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

# ── 9. Create tag ───────────────────────────────────────────

if $DRY_RUN; then
    echo "  (dry-run) git tag -a '$TAG' -m 'chore: release v$VERSION'"
    echo "Done (dry-run)."
else
    git tag -a "$TAG" -m "chore: release v$VERSION"
    echo "Created tag '$TAG'."
    echo ""
    echo "To push tag:"
    echo "  git push origin $TAG"
    echo ""
    echo "To push tag + commits:"
    echo "  git push origin master --tags"
    echo ""
    echo "To remove tag (local):"
    echo "  git tag -d $TAG"
fi
