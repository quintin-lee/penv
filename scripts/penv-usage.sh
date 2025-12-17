#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "${SCRIPT_DIR}/env.sh"

# Set default sort order
SORT_BY="size"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --sort-by=*)
            SORT_BY="${1#*=}"
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: penv usage [--sort-by=size|name]"
            exit 1
            ;;
    esac
    shift
done

# Check if VENV_STORAGE_DIR exists
if [ ! -d "$VENV_STORAGE_DIR" ]; then
    echo "No virtual environments found."
    exit 0
fi

# Store environment info
declare -a ENV_NAMES
declare -a ENV_SIZES
declare -a ENV_PATHS

# Collect environment info
env_index=0
for env_path in "${VENV_STORAGE_DIR}"/*/
do
    # Skip if no matches found
    if [[ -d "$env_path" ]]; then
        env_name=$(basename "$env_path")
        
        # Calculate size using du command
        env_size=$(du -sh "$env_path" 2>/dev/null | cut -f1)
        if [ -n "$env_size" ]; then
            ENV_NAMES[$env_index]="$env_name"
            ENV_SIZES[$env_index]="$env_size"
            ENV_PATHS[$env_index]="$env_path"
            ((env_index++))
        fi
    fi
done

# If no environments found, show message
if [ $env_index -eq 0 ]; then
    echo "No virtual environments found."
    exit 0
fi

# Print header
echo "Virtual environment disk usage in '${VENV_STORAGE_DIR}':"
echo

# Print table header
printf "%-30s %10s\n" "Environment" "Size"
printf "%-30s %10s\n" "-----------" "----"

# Sort environments by size or name
if [[ "$SORT_BY" == "name" ]]; then
    # Sort by name
    IFS=$'\n' sorted_data=($(for i in "${!ENV_NAMES[@]}"; do
        echo "${ENV_NAMES[$i]}|${ENV_SIZES[$i]}"
    done | sort))
else
    # Sort by size - this is more complex since we're dealing with human-readable sizes
    # For now, we'll sort by the size values directly, which will work for same units
    IFS=$'\n' sorted_data=($(for i in "${!ENV_NAMES[@]}"; do
        echo "${ENV_SIZES[$i]}|${ENV_NAMES[$i]}"
    done | sort -h))
    # Extract name and size in correct order after sorting
    formatted_data=()
    for item in "${sorted_data[@]}"; do
        size=$(echo "$item" | cut -d'|' -f1)
        name=$(echo "$item" | cut -d'|' -f2)
        formatted_data+=("$name|$size")
    done
    sorted_data=("${formatted_data[@]}")
fi

unset IFS

# Print sorted environments
for item in "${sorted_data[@]}"; do
    if [ -n "$item" ]; then
        env_name=$(echo "$item" | cut -d'|' -f1)
        env_size=$(echo "$item" | cut -d'|' -f2)
        printf "%-30s %10s\n" "$env_name" "$env_size"
    fi
done

echo
echo "Total environments: $env_index"

# Calculate total size
total_size=$(du -shc "${VENV_STORAGE_DIR}"/*/ 2>/dev/null | tail -n 1 | cut -f1)
if [ -n "$total_size" ]; then
    echo "Total disk usage: $total_size"
fi