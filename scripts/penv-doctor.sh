#!/usr/bin/env bash
# penv doctor — Diagnose penv system health
#
# Checks: python3, expect, storage dir, stale markers,
#         broken environments, completion config, systemd service

SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "${SCRIPT_DIR}/env.sh"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: penv doctor"
    echo ""
    echo "Diagnose penv system health."
    echo ""
    echo "Checks dependencies (python3, expect, git),"
    echo "storage directory permissions, activation marker"
    echo "integrity, environment health, shell completion,"
    echo "systemd service, and configuration file."
    echo ""
    echo "Returns exit code 0 if no failures."
    echo ""
    echo "Example:"
    echo "  penv doctor"
    exit 0
fi

PASS=0
FAIL=0
WARN=0

pass() { echo "  ✓ $1"; ((PASS++)); }
fail() { echo "  ✗ $1"; ((FAIL++)); }
warn() { echo "  ⚠ $1"; ((WARN++)); }

echo "penv Doctor — System Health Check"
echo ""

# ── Dependency checks ──

echo "--- Dependencies ---"

if command -v python3 &>/dev/null; then
    ver=$(python3 --version 2>&1 | cut -d' ' -f2)
    pass "python3 found ($ver)"
else
    fail "python3 not found in PATH"
fi

if command -v expect &>/dev/null; then
    ver=$(expect -v 2>&1 | grep -oP 'version \K[0-9.]+' || echo "?")
    pass "expect found (${ver})"
else
    fail "expect not found (required for penv activate)"
fi

if command -v git &>/dev/null; then
    pass "git found"
else
    warn "git not found"
fi

echo ""

# ── Environment checks ──

echo "--- Storage ---"

if [[ -d "$VENV_STORAGE_DIR" ]]; then
    pass "VENV_STORAGE_DIR exists (${VENV_STORAGE_DIR})"
    if [[ -r "$VENV_STORAGE_DIR" && -w "$VENV_STORAGE_DIR" ]]; then
        pass "VENV_STORAGE_DIR is readable and writable"
    else
        fail "VENV_STORAGE_DIR has incorrect permissions"
    fi
else
    fail "VENV_STORAGE_DIR does not exist (${VENV_STORAGE_DIR})"
fi

echo ""

# ── Stale markers ──

echo "--- Activation Markers ---"

stale_markers=0
for marker in "${VENV_STORAGE_DIR}"/*.activate; do
    [[ -f "$marker" ]] || continue
    env_name=$(basename "$marker" .activate)
    if [[ ! -d "${VENV_STORAGE_DIR}/${env_name}" ]]; then
        warn "Stale .activate marker: ${env_name} (environment missing)"
        ((stale_markers++))
    fi
done

if (( stale_markers == 0 )); then
    pass "No stale activation markers"
fi

for pidfile in "${VENV_STORAGE_DIR}"/*.pid; do
    [[ -f "$pidfile" ]] || continue
    env_name=$(basename "$pidfile" .pid)
    if [[ ! -d "${VENV_STORAGE_DIR}/${env_name}" ]]; then
        warn "Stale .pid file: ${env_name} (environment missing)"
    fi
done

echo ""

# ── Broken environments ──

echo "--- Environment Integrity ---"

broken_count=0
broken_list=""
for env_dir in "${VENV_STORAGE_DIR}"/*/; do
    [[ -d "$env_dir" ]] || continue
    env_name=$(basename "$env_dir")
    issues=""

    if [[ ! -f "${env_dir}/pyvenv.cfg" ]]; then
        issues="${issues}missing pyvenv.cfg; "
    fi
    if [[ ! -f "${env_dir}/bin/python" && ! -f "${env_dir}/bin/python3" ]]; then
        issues="${issues}missing python binary; "
    fi
    if [[ ! -f "${env_dir}/bin/activate" ]]; then
        issues="${issues}missing activate script"
    fi

    if [[ -n "$issues" ]]; then
        warn "${env_name}: ${issues}"
        broken_list="${broken_list}  ${env_name}\n"
        ((broken_count++))
    fi
done

if (( broken_count == 0 )); then
    pass "All environments appear healthy"
else
    echo ""
    echo "  Tip: 'penv prune' to remove broken environments."
fi

echo ""

# ── Systemd service ──

echo "--- Service ---"

if command -v systemctl &>/dev/null; then
    if systemctl is-enabled penv.service &>/dev/null; then
        pass "penv.service is enabled"
        if systemctl is-active penv.service &>/dev/null; then
            pass "penv.service is running"
        else
            warn "penv.service is enabled but not running"
        fi
    else
        warn "penv.service is not configured (optional)"
    fi
else
    warn "systemd not available (non-Linux or no systemd)"
fi

echo ""

# ── Shell completion ──

echo "--- Shell Completion ---"

completion_count=0
if [[ -f "/usr/share/bash-completion/completions/penv" ]]; then
    pass "bash completion installed (system)"
    ((completion_count++))
fi
if [[ -f "/usr/local/share/zsh/site-functions/_penv" || -f "/usr/share/zsh/site-functions/_penv" ]]; then
    pass "zsh completion installed"
    ((completion_count++))
fi
if [[ -d "$HOME/.config/fish/completions" && -f "$HOME/.config/fish/completions/penv.fish" ]]; then
    pass "fish completion installed"
    ((completion_count++))
fi
if (( completion_count == 0 )); then
    warn "No shell completion files found (install with 'make install' or package)"
fi

echo ""

# ── Config ──

echo "--- Configuration ---"

if [[ -f "$PENV_CONFIG_FILE" ]]; then
    pass "Config file exists (${PENV_CONFIG_FILE})"
    while IFS='=' read -r key value; do
        [[ -z "$key" || "$key" == \#* ]] && continue
        echo "       ${key}=${value}"
    done < "$PENV_CONFIG_FILE"
else
    warn "No config file (${PENV_CONFIG_FILE})"
fi

echo ""

# ── Summary ──

echo "--- Summary: ${PASS} passed, ${FAIL} failed, ${WARN} warnings ---"

if (( FAIL > 0 )); then
    exit 1
fi
exit 0
