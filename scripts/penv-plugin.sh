#!/usr/bin/env bash
# penv plugin — List and manage penv plugins

SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "${SCRIPT_DIR}/env.sh"

# Default plugin directory if not set
PENV_PLUGIN_DIR="${PENV_PLUGIN_DIR:-${HOME}/.config/penv/plugins}"

list_plugins() {
    if [[ ! -d "$PENV_PLUGIN_DIR" ]]; then
        echo "No plugins directory found (${PENV_PLUGIN_DIR})."
        echo ""
        echo "To add plugins:"
        echo "  1. mkdir -p \"${PENV_PLUGIN_DIR}\""
        echo "  2. Create an executable script named <command>.sh"
        echo "  3. Run 'penv <command>' to use it"
        exit 0
    fi

    plugins=()
    while IFS= read -r -d '' file; do
        cmd_name=$(basename "$file" .sh)
        plugins+=("$cmd_name")
    done < <(find "$PENV_PLUGIN_DIR" -maxdepth 1 -name '*.sh' -type f -executable -print0 2>/dev/null || true)

    if [[ ${#plugins[@]} -eq 0 ]]; then
        echo "Plugins directory: ${PENV_PLUGIN_DIR}"
        echo "No plugins installed."
        echo ""
        echo "To add a plugin, place an executable .sh file in:"
        echo "  ${PENV_PLUGIN_DIR}/"
        echo ""
        echo "Example: ${PENV_PLUGIN_DIR}/hello.sh → 'penv hello'"
        exit 0
    fi

    echo "Plugins (${PENV_PLUGIN_DIR}):"
    for plugin in "${plugins[@]}"; do
        echo "  ${plugin}"
    done
}

case "${1:-list}" in
    list)
        list_plugins
        ;;
    *)
        die "Usage: penv plugin [list]"
        ;;
esac
