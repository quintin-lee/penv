#!/usr/bin/env bash
# penv init — One-command penv initialization
#
# Interactive setup that configures:
#   - Shell completion
#   - Shell profile (auto-activation hook)
#   - systemd service (auto-clean)
#   - Plugin directory
#   - Config file
#
# Usage: penv init [--yes]
#   --yes    Non-interactive mode — apply all changes

SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "${SCRIPT_DIR}/env.sh"

NON_INTERACTIVE=false
if [[ "${1:-}" == "--yes" || "${1:-}" == "-y" ]]; then
    NON_INTERACTIVE=true
fi

confirm() {
    if $NON_INTERACTIVE; then
        return 0
    fi
    local prompt="${1} [Y/n] "
    local default=true
    if [[ "${2:-}" == "no" ]]; then
        prompt="${1} [y/N] "
        default=false
    fi
    echo -n "$prompt"
    read -r REPLY
    if [[ -z "$REPLY" ]]; then
        $default && return 0 || return 1
    fi
    [[ "$REPLY" =~ ^[Yy]$ ]]
}

echo "penv init — One-command setup"
echo "============================="
echo ""

# ── 1. Detect shell ──

detect_shell() {
    local shell_name
    shell_name=$(basename "${SHELL:-bash}" 2>/dev/null || echo "bash")
    case "$shell_name" in
        zsh|bash|fish) echo "$shell_name" ;;
        *) echo "bash" ;;
    esac
}

SHELL_NAME=$(detect_shell)
echo "Detected shell: ${SHELL_NAME}"
echo ""

# ── 2. Shell completion ──

install_completion() {
    local src="${SCRIPT_DIR}/penv-completion.bash"
    local done=false

    if [[ "$SHELL_NAME" == "bash" ]]; then
        local dest="/usr/local/share/bash-completion/completions/penv"
        if [[ ! -f "$dest" ]]; then
            if confirm "Install bash completion (${dest})?"; then
                if mkdir -p "$(dirname "$dest")" 2>/dev/null && cp "$src" "$dest" 2>/dev/null; then
                    echo "  ✓ bash completion installed"
                    done=true
                else
                    echo "  ⚠  Could not install to ${dest} (need sudo?)"
                fi
            fi
        else
            echo "  ✓ bash completion already installed"
            done=true
        fi
    fi

    if [[ "$SHELL_NAME" == "zsh" ]]; then
        local dest="/usr/local/share/zsh/site-functions/_penv"
        if [[ ! -f "$dest" ]]; then
            if confirm "Install zsh completion (${dest})?"; then
                if mkdir -p "$(dirname "$dest")" 2>/dev/null && cp "$src" "$dest" 2>/dev/null; then
                    echo "  ✓ zsh completion installed"
                    done=true
                else
                    echo "  ⚠  Could not install to ${dest} (need sudo?)"
                fi
            fi
        else
            echo "  ✓ zsh completion already installed"
            done=true
        fi
    fi

    if [[ "$SHELL_NAME" == "fish" ]]; then
        local fish_dir="${HOME}/.config/fish/completions"
        local dest="${fish_dir}/penv.fish"
        local src_fish="${SCRIPT_DIR}/penv-completion.fish"
        if [[ -f "$src_fish" && ! -f "$dest" ]]; then
            if confirm "Install fish completion?"; then
                mkdir -p "$fish_dir"
                if cp "$src_fish" "$dest" 2>/dev/null; then
                    echo "  ✓ fish completion installed"
                    done=true
                else
                    echo "  ⚠  Could not install fish completion"
                fi
            fi
        elif [[ -f "$dest" ]]; then
            echo "  ✓ fish completion already installed"
            done=true
        fi
    fi

    $done
}

echo "--- Shell Completion ---"
install_completion
echo ""

# ── 3. Profile hook ──

install_profile_hook() {
    local hook_line="# Source penv auto-activation helper
source \"${SCRIPT_DIR}/penv-auto-activate.sh\""
    local rc_file

    case "$SHELL_NAME" in
        bash) rc_file="${HOME}/.bashrc" ;;
        zsh)  rc_file="${HOME}/.zshrc" ;;
        fish) rc_file="${HOME}/.config/fish/config.fish" ;;
        *)    return 1 ;;
    esac

    if [[ ! -f "$rc_file" ]]; then
        if confirm "Create ${rc_file} with penv auto-activation?"; then
            mkdir -p "$(dirname "$rc_file")"
            {
                echo ""
                echo "$hook_line"
            } >> "$rc_file"
            echo "  ✓ Created ${rc_file} with penv auto-activation"
            return 0
        fi
        return 1
    fi

    if grep -q "penv-auto-activate" "$rc_file" 2>/dev/null; then
        echo "  ✓ penv auto-activation already in ${rc_file}"
        return 0
    fi

    if confirm "Add penv auto-activation to ${rc_file}?"; then
        {
            echo ""
            echo "$hook_line"
        } >> "$rc_file"
        echo "  ✓ Added penv auto-activation to ${rc_file}"
    fi
}

echo "--- Shell Profile ---"
install_profile_hook
echo ""

# ── 4. systemd service ──

install_systemd_service() {
    local src="${SCRIPT_DIR}/penv.service"
    local dest="/etc/systemd/system/penv.service"

    if ! command -v systemctl &>/dev/null; then
        echo "  ⚠  systemd not available (non-Linux or no systemd)"
        return 1
    fi

    if systemctl is-enabled penv.service &>/dev/null; then
        echo "  ✓ penv.service already enabled and running"
        return 0
    fi

    if [[ ! -f "$dest" ]]; then
        if confirm "Install penv.service (${dest})?"; then
            if cp "$src" "$dest" 2>/dev/null; then
                if systemctl daemon-reload && systemctl enable penv.service && systemctl start penv.service; then
                    echo "  ✓ penv.service installed, enabled, and started"
                    return 0
                else
                    echo "  ⚠  Service file installed but failed to enable/start (need sudo?)"
                    return 1
                fi
            else
                echo "  ⚠  Could not install service file (need sudo?)"
                return 1
            fi
        fi
    else
        echo "  ✓ penv.service already installed"
        if confirm "Enable and start penv.service?"; then
            systemctl enable penv.service && systemctl start penv.service
            echo "  ✓ penv.service enabled and started"
        fi
    fi
}

echo "--- Systemd Service ---"
install_systemd_service
echo ""

# ── 5. Plugin directory ──

if [[ ! -d "$PENV_PLUGIN_DIR" ]]; then
    if confirm "Create plugin directory (${PENV_PLUGIN_DIR})?"; then
        mkdir -p "$PENV_PLUGIN_DIR"
        echo "  ✓ Created ${PENV_PLUGIN_DIR}"
    fi
else
    echo "✓ Plugin directory exists (${PENV_PLUGIN_DIR})"
fi
echo ""

# ── 6. Config file ──

if [[ ! -f "$PENV_CONFIG_FILE" ]]; then
    if confirm "Create default config file (${PENV_CONFIG_FILE})?"; then
        mkdir -p "$(dirname "$PENV_CONFIG_FILE")"
        {
            echo "# penv configuration file"
            echo "# Created by 'penv init'"
            echo ""
            echo "# Default Python executable for 'penv create'"
            echo "# default_python=python3"
            echo ""
            echo "# Override the virtual environment storage directory"
            echo "# storage_dir=$HOME/.cache/python-venv"
        } > "$PENV_CONFIG_FILE"
        echo "  ✓ Created ${PENV_CONFIG_FILE}"
    fi
else
    echo "✓ Config file exists (${PENV_CONFIG_FILE})"
fi
echo ""

# ── Summary ──

echo "============================="
echo "penv init complete!"
echo ""
echo "To start using penv with auto-activation:"
if [[ "$SHELL_NAME" == "fish" ]]; then
    echo "  source ~/.config/fish/config.fish"
else
    echo "  source ~/.${SHELL_NAME}rc"
fi
echo ""
echo "Quick start:"
echo "  penv create myproject"
echo "  penv activate myproject"
echo "  penv doctor"
echo "============================="
