#!/usr/bin/bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source ${SCRIPT_DIR}/env.sh

# Initialize maximum width
MAX_NAME_WIDTH=4        # Minimum width for "Name"
MAX_DESCRIPTION_WIDTH=11    # Minimum width for "Description"
MAX_VERSION_WIDTH=20

# Store all virtual environment names and descriptions
declare -A ENV_NAMES
declare -A ENV_DESCRIPTIONS
declare -a ENV_LIST

# Single traversal to collect environment info and determine column widths
for env_name in $(ls ${VENV_STORAGE_DIR}/ 2>/dev/null)
do
    ENV_DIR="${VENV_STORAGE_DIR}/${env_name}"
    DESCRIPTION_FILE="${ENV_DIR}/description.txt"

    if [ ! -d "$ENV_DIR" ]
    then
        continue
    fi
    
    # Read description if available
    if [ -f "${DESCRIPTION_FILE}" ]; then
        DESCRIPTION=$(cat "${DESCRIPTION_FILE}" 2>/dev/null)
        if [ $? -ne 0 ]; then
            DESCRIPTION=""
        fi
    else
        DESCRIPTION=""
    fi
    
    # Store name and description
    ENV_NAMES[$env_name]=$env_name
    ENV_DESCRIPTIONS[$env_name]=$DESCRIPTION
    ENV_LIST+=($env_name)
    
    # Update maximum width
    NAME_LENGTH=$(echo -n ${env_name} | wc -L)
    DESCRIPTION_LENGTH=$(echo -n ${DESCRIPTION} | wc -L)
    
    if (( NAME_LENGTH > MAX_NAME_WIDTH )); then
        MAX_NAME_WIDTH=$NAME_LENGTH
    fi
    
    if (( DESCRIPTION_LENGTH > MAX_DESCRIPTION_WIDTH )); then
        MAX_DESCRIPTION_WIDTH=$DESCRIPTION_LENGTH
    fi
done

# If no virtual environments found, show message
if [ ${#ENV_LIST[@]} -eq 0 ]; then
    echo "No virtual environments found."
    exit 0
fi

# Sort environment names
IFS=$'\n' ENV_LIST=($(sort <<<"${ENV_LIST[*]}"))
unset IFS

# Print header
printf "%-${MAX_NAME_WIDTH}s    %-${MAX_DESCRIPTION_WIDTH}s    %-${MAX_VERSION_WIDTH}s\n" "Name" "Description" "Python Version"
printf "%-${MAX_NAME_WIDTH}s    %-${MAX_DESCRIPTION_WIDTH}s    %-${MAX_VERSION_WIDTH}s\n" "----" "-----------" "--------------"

# Print sorted environments with aligned output
for env_name in "${ENV_LIST[@]}"
do
    # Get Python version, handle errors gracefully
    PYTHON_VERSION=$(${VENV_STORAGE_DIR}/$env_name/bin/python --version 2>/dev/null | cut -d' ' -f2)
    if [ -z "$PYTHON_VERSION" ]; then
        PYTHON_VERSION="Unknown"
    fi
    
    DESCRIPTION=${ENV_DESCRIPTIONS[$env_name]}
    printf "%-${MAX_NAME_WIDTH}s    %-${MAX_DESCRIPTION_WIDTH}s    %-${MAX_VERSION_WIDTH}s\n" "${env_name}" "${DESCRIPTION}" "${PYTHON_VERSION}"
done