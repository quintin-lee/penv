#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "${SCRIPT_DIR}/env.sh"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: penv list [--sort-by=name|date] [<filter>] [--json]"
    echo ""
    echo "List all virtual environments."
    echo ""
    echo "Options:"
    echo "  --sort-by=name    Sort alphabetically (default)"
    echo "  --sort-by=date    Sort by creation date"
    echo "  --json            Output in JSON format"
    echo "  <filter>          Filter by environment name pattern"
    echo ""
    echo "Examples:"
    echo "  penv list"
    echo "  penv list --sort-by=date"
    echo "  penv list myproj"
    echo "  penv list --json"
    exit 0
fi

# Default values
SORT_BY="name"
FILTER_PATTERN=""
OUTPUT_MODE="table"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --sort-by=*)
            SORT_BY="${1#*=}"
            ;;
        --filter=*)
            FILTER_PATTERN="${1#*=}"
            ;;
        --json)
            OUTPUT_MODE="json"
            ;;
        *)
            die "Unknown option: $1"
            echo "Usage: penv list [--sort-by=name|date] [--filter=pattern] [--json]"
            ;;
    esac
    shift
done

# Initialize maximum width
MAX_NAME_WIDTH=4        # Minimum width for "Name"
MAX_DESCRIPTION_WIDTH=11    # Minimum width for "Description"
MAX_VERSION_WIDTH=20

# Store all virtual environment names and descriptions
    declare -A ENV_DESCRIPTIONS
declare -a ENV_LIST
declare -A ENV_PYTHON_VERSIONS
declare -A ENV_ACTIVATED

# Get currently activated environment
CURRENT_ENV_FILE=$(ls "${VENV_STORAGE_DIR}"/*.activate 2>/dev/null | head -n 1)
CURRENT_ENV=""
if [[ -n "$CURRENT_ENV_FILE" ]]; then
    CURRENT_ENV=$(basename "$CURRENT_ENV_FILE" .activate)
fi

# Single traversal to collect environment info and determine column widths
for env_dir_path in "${VENV_STORAGE_DIR}"/*/
do
    # Skip if no matches found - suppress error if no directories match
    if [[ -d "$env_dir_path" ]]; then
        env_name=$(basename "$env_dir_path")
    else
        continue
    fi

    # Apply filter if specified
    if [[ -n "$FILTER_PATTERN" ]] && [[ ! "$env_name" =~ $FILTER_PATTERN ]]; then
        continue
    fi

    ENV_DIR="$env_dir_path"
    DESCRIPTION_FILE="${ENV_DIR}/description.txt"

    if [ ! -d "$ENV_DIR" ]
    then
        continue
    fi
    
    # Check if environment is activated
    ACTIVATED=false
    if [ -f "${VENV_STORAGE_DIR}/${env_name}.activate" ]; then
        ACTIVATED=true
    fi

    # Read description if available
    if [ -f "${DESCRIPTION_FILE}" ]; then
        DESCRIPTION=$(cat "${DESCRIPTION_FILE}" 2>/dev/null || true)
    else
        DESCRIPTION=""
    fi

    # Get Python version with timeout to prevent hanging
    PYTHON_VERSION=$(timeout 5s "${VENV_STORAGE_DIR}/${env_name}/bin/python" --version 2>/dev/null | cut -d' ' -f2)
    if [ -z "$PYTHON_VERSION" ]; then
        PYTHON_VERSION="Unknown"
    fi

    # Store name, description, version and activation status
    ENV_DESCRIPTIONS[$env_name]=$DESCRIPTION
    ENV_PYTHON_VERSIONS[$env_name]=$PYTHON_VERSION
    ENV_ACTIVATED[$env_name]=$ACTIVATED
    ENV_LIST+=("$env_name")

    # Update maximum width
    NAME_LENGTH=${#env_name}
    DESCRIPTION_LENGTH=${#DESCRIPTION}
    VERSION_LENGTH=${#PYTHON_VERSION}

    if (( NAME_LENGTH > MAX_NAME_WIDTH )); then
        MAX_NAME_WIDTH=$NAME_LENGTH
    fi

    if (( DESCRIPTION_LENGTH > MAX_DESCRIPTION_WIDTH )); then
        MAX_DESCRIPTION_WIDTH=$DESCRIPTION_LENGTH
    fi

    if (( VERSION_LENGTH > MAX_VERSION_WIDTH )); then
        MAX_VERSION_WIDTH=$VERSION_LENGTH
    fi
done

# JSON-encode a string (escape \ and ")
json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    printf "%s" "$s"
}

# If no virtual environments found, show message
if [ ${#ENV_LIST[@]} -eq 0 ]; then
    if [[ "$OUTPUT_MODE" == "json" ]]; then
        echo "{\"environments\":[],\"total\":0,\"storage_dir\":\"$(json_escape "$VENV_STORAGE_DIR")\"}"
    else
        if [[ -n "$FILTER_PATTERN" ]]; then
            echo "No virtual environments found matching pattern: $FILTER_PATTERN"
        else
            echo "No virtual environments found."
        fi
    fi
    exit 0
fi

# Sort environment names
if [[ "$SORT_BY" == "date" ]]; then
    # Sort by creation date (oldest first)
    mapfile -t ENV_LIST < <(for env in "${ENV_LIST[@]}"; do
        echo "$(stat -c %Y "${VENV_STORAGE_DIR}/${env}") $env"
    done | sort -n | cut -d' ' -f2-)
else
    # Sort by name (default)
    mapfile -t ENV_LIST < <(for env in "${ENV_LIST[@]}"; do echo "$env"; done | sort)
fi

unset IFS

# JSON output mode
if [[ "$OUTPUT_MODE" == "json" ]]; then
    echo -n '{"environments":['
    first=true
    for env_name in "${ENV_LIST[@]}"; do
        $first || echo -n ','
        first=false
        DESCRIPTION=${ENV_DESCRIPTIONS[$env_name]}
        PYTHON_VERSION=${ENV_PYTHON_VERSIONS[$env_name]}
        ACTIVATED=${ENV_ACTIVATED[$env_name]}
        SIZE=$(du -sh "${VENV_STORAGE_DIR}/${env_name}/" 2>/dev/null | cut -f1)
        echo -n "{\"name\":\"$(json_escape "$env_name")\""
        echo -n ",\"python\":\"$(json_escape "$PYTHON_VERSION")\""
        echo -n ",\"activated\":${ACTIVATED}"
        echo -n ",\"size\":\"$(json_escape "$SIZE")\""
        if [[ -n "$DESCRIPTION" ]]; then
            echo -n ",\"description\":\"$(json_escape "$DESCRIPTION")\""
        fi
        echo -n '}'
    done
    echo -n "],\"total\":${#ENV_LIST[@]}"
    echo -n ",\"storage_dir\":\"$(json_escape "$VENV_STORAGE_DIR")\""
    if [[ -n "$CURRENT_ENV" ]]; then
        echo -n ",\"currently_active\":\"$(json_escape "$CURRENT_ENV")\""
    fi
    echo '}'
    exit 0
fi

# Print header with enhanced formatting
echo "Virtual environments in '${VENV_STORAGE_DIR}':"
echo

# Print table header
printf "\033[1m%-${MAX_NAME_WIDTH}s    %-${MAX_DESCRIPTION_WIDTH}s    %-${MAX_VERSION_WIDTH}s    %s\033[0m\n" "Name" "Description" "Python Version" "Status"
printf "%-${MAX_NAME_WIDTH}s    %-${MAX_DESCRIPTION_WIDTH}s    %-${MAX_VERSION_WIDTH}s    %s\n" "$(printf '%*s' "$MAX_NAME_WIDTH" '' | tr ' ' '-')" "-----------" "--------------" "------"

# Print sorted environments with aligned output and status indicators
for env_name in "${ENV_LIST[@]}"
do
    DESCRIPTION=${ENV_DESCRIPTIONS[$env_name]}
    PYTHON_VERSION=${ENV_PYTHON_VERSIONS[$env_name]}
    ACTIVATED=${ENV_ACTIVATED[$env_name]}
    
    # Determine status display
    if [ "$ACTIVATED" = true ]; then
        STATUS="Active"
        # Print active environments in green
        printf "\033[32m%-${MAX_NAME_WIDTH}s    %-${MAX_DESCRIPTION_WIDTH}s    %-${MAX_VERSION_WIDTH}s    %s\033[0m\n" "${env_name}" "${DESCRIPTION}" "${PYTHON_VERSION}" "${STATUS}"
    else
        STATUS="Inactive"
        # Print inactive environments in default color
        printf "%-${MAX_NAME_WIDTH}s    %-${MAX_DESCRIPTION_WIDTH}s    %-${MAX_VERSION_WIDTH}s    %s\n" "${env_name}" "${DESCRIPTION}" "${PYTHON_VERSION}" "${STATUS}"
    fi
done

echo
echo "Total: ${#ENV_LIST[@]} virtual environments"
if [[ -n "$CURRENT_ENV" ]]; then
    echo "Currently active: ${CURRENT_ENV}"
fi