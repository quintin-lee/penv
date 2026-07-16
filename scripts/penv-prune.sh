#!/usr/bin/env bash
# penv prune — Remove broken virtual environments
#
# Scans all environments and identifies ones that are damaged:
#   - Missing Python interpreter (bin/python or bin/python3)
#   - Missing pyvenv.cfg
#   - Missing bin/activate
#
# With --force, skips confirmation.

SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "${SCRIPT_DIR}/env.sh"

FORCE=false
if [[ "${1:-}" == "--force" ]]; then
    FORCE=true
fi

# ── Scan for broken environments ──

broken_envs=()
broken_reasons=()

for env_dir in "${VENV_STORAGE_DIR}"/*/; do
    [[ -d "$env_dir" ]] || continue
    env_name=$(basename "$env_dir")
    reasons=""

    if [[ ! -f "${env_dir}/pyvenv.cfg" ]]; then
        reasons="${reasons}missing pyvenv.cfg, "
    fi
    if [[ ! -f "${env_dir}/bin/python" && ! -f "${env_dir}/bin/python3" ]]; then
        reasons="${reasons}missing python binary, "
    fi
    if [[ ! -f "${env_dir}/bin/activate" ]]; then
        reasons="${reasons}missing activate script"
    fi

    # Trim trailing space/comma
    reasons="${reasons%, }"
    reasons="${reasons%,}"

    if [[ -n "$reasons" ]]; then
        broken_envs+=("$env_name")
        broken_reasons+=("$reasons")
    fi
done

# ── Report ──

if [[ ${#broken_envs[@]} -eq 0 ]]; then
    echo "No broken environments found."
    exit 0
fi

echo "Found ${#broken_envs[@]} broken environment(s):"
echo ""
for i in "${!broken_envs[@]}"; do
    printf "  %-20s %s\n" "${broken_envs[$i]}" "${broken_reasons[$i]}"
done

echo ""

# ── Confirm ──

if ! $FORCE; then
    echo -n "Remove these environments? [y/N] "
    read -r CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# ── Remove ──

removed=0
for env_name in "${broken_envs[@]}"; do
    env_dir="${VENV_STORAGE_DIR}/${env_name}"

    # Remove environment directory
    if rm -rf "$env_dir"; then
        echo "  Removed ${env_name}"
        ((removed++))
    else
        echo "  Error: Failed to remove ${env_name}" >&2
    fi

    # Clean up activation markers
    if [[ -f "${VENV_STORAGE_DIR}/${env_name}.activate" ]]; then
        rm -f "${VENV_STORAGE_DIR}/${env_name}.activate"
    fi
    if [[ -f "${VENV_STORAGE_DIR}/${env_name}.pid" ]]; then
        rm -f "${VENV_STORAGE_DIR}/${env_name}.pid"
    fi
done

echo ""
echo "Removed ${removed}/${#broken_envs[@]} broken environment(s)."
