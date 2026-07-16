#!/usr/bin/env bash
# penv config — Manage penv configuration

SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "${SCRIPT_DIR}/env.sh"

CONFIG_DIR="${HOME}/.config/penv"
CONFIG_FILE="${CONFIG_DIR}/config"

# Ensure config directory exists
if [[ ! -d "$CONFIG_DIR" ]]; then
    mkdir -p "$CONFIG_DIR" 2>/dev/null || die "Cannot create config directory: $CONFIG_DIR"
fi

# Ensure config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    touch "$CONFIG_FILE" 2>/dev/null || die "Cannot create config file: $CONFIG_FILE"
fi

# Supported config keys and their descriptions
declare -A CONFIG_KEYS
CONFIG_KEYS["default_python"]="Default Python executable for 'penv create' (e.g. python3.11)"
CONFIG_KEYS["storage_dir"]="Override the virtual environment storage directory"

list_config() {
    if [[ ! -s "$CONFIG_FILE" ]]; then
        echo "No configuration set."
        echo ""
        echo "Available settings:"
        for key in "${!CONFIG_KEYS[@]}"; do
            printf "  %-20s %s\n" "$key" "${CONFIG_KEYS[$key]}"
        done
        return
    fi

    echo "Configuration (${CONFIG_FILE}):"
    echo ""
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ -z "$key" || "$key" == \#* ]] && continue
        printf "  %-20s = %s\n" "$key" "$value"
    done < "$CONFIG_FILE"
    echo ""
    echo "Available settings:"
    for key in "${!CONFIG_KEYS[@]}"; do
        printf "  %-20s %s\n" "$key" "${CONFIG_KEYS[$key]}"
    done
}

get_config() {
    local key=$1
    local value

    if ! grep -q "^${key}=" "$CONFIG_FILE" 2>/dev/null; then
        die "Setting '$key' is not configured."
    fi

    value=$(grep "^${key}=" "$CONFIG_FILE" | sed "s/^${key}=//" | head -n 1)
    echo "$value"
}

set_config() {
    local key=$1
    local value=$2

    # Validate key
    if [[ -z "${CONFIG_KEYS[$key]:-}" ]]; then
        die "Unknown setting: '$key'. Available: ${!CONFIG_KEYS[*]}"
    fi

    # Validate value
    if [[ -z "$value" ]]; then
        die "Value for '$key' cannot be empty."
    fi

    # For storage_dir, validate it's an absolute path
    if [[ "$key" == "storage_dir" && "$value" != /* ]]; then
        die "storage_dir must be an absolute path (starting with /)."
    fi

    # Update or append
    if grep -q "^${key}=" "$CONFIG_FILE" 2>/dev/null; then
        if [[ "$(uname -s)" == "Darwin" ]]; then
            sed -i '' "s|^${key}=.*|${key}=${value}|" "$CONFIG_FILE"
        else
            sed -i "s|^${key}=.*|${key}=${value}|" "$CONFIG_FILE"
        fi
    else
        echo "${key}=${value}" >> "$CONFIG_FILE"
    fi

    echo "Set ${key}=${value}"
    echo "Config file: ${CONFIG_FILE}"
}

# --- Main ---

if [[ $# -eq 0 ]]; then
    list_config
    exit 0
fi

case "$1" in
    list)
        list_config
        ;;
    get)
        if [[ $# -lt 2 ]]; then
            die "Usage: penv config get <key>"
        fi
        get_config "$2"
        ;;
    set)
        if [[ $# -lt 3 ]]; then
            die "Usage: penv config set <key> <value>"
        fi
        set_config "$2" "$3"
        ;;
    *)
        die "Usage: penv config [list|get|set]"
        ;;
esac
