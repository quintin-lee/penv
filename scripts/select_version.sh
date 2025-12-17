#!/usr/bin/env bash

all_real_paths=()

# Function: Get the actual file path in case of symbolic link
get_real_path() {
    local file=$1
    if [[ -L "$file" ]]; then
        # Read the path of the actual file the symlink points to
        readlink -f "$file"
    else
        echo "$file"
    fi
}

# Function: Print Python version
print_python_version() {
    local python_executable=$1
    if [[ -x "$python_executable" ]]; then
        local version_output
        version_output=$(timeout 2s "$python_executable" --version 2>&1)
        if [ $? -eq 0 ]; then
            echo "Python $(echo "$version_output" | cut -d' ' -f2)"
        else
            echo "Python (invalid)"
        fi
    fi
}

# Check common Python executable paths
common_paths=(/usr/bin /usr/local/bin /opt $HOME/.local/bin)

# Find all Python executables using find command
# Note: This may take some time depending on the scale of the file system
for path in "${common_paths[@]}"; do
    while IFS= read -r executable; do
        # Check if file is executable
        if [[ -x "$executable" ]]; then
            if [[ ! "$executable" =~ /bin/python.* || "$executable" =~ config$ || "$executable" =~ script$ ]]; then
                continue
            fi
            real_path=$(get_real_path "$executable")
            if [[ -n "$real_path" ]]; then
                all_real_paths+=("$real_path")
            fi
        fi
    done < <(find "$path" -type f -name "python*" 2>/dev/null)
done

# Remove duplicate actual file paths
unique_paths=($(printf "%s\n" "${all_real_paths[@]}" | sort -u))

# Show menu and allow user to select
show_menu() {
    printf "\033c"  # Clear screen using ANSI escape code (more portable than 'clear')
    echo "Choose a Python version:"
    for i in ${!unique_paths[@]}; do
        if [ "$i" -eq "$current_index" ]; then
            echo "-> $i: $(print_python_version "${unique_paths[$i]}")"
        else
            echo "   $i: $(print_python_version "${unique_paths[$i]}")"
        fi
    done
    echo
    echo "Use up/down arrow keys to navigate and Enter to select, q to quit."
}

# Initial selection index
current_index=0

# Main loop - improved terminal compatibility by reading 3-character sequences for arrow keys
while true; do
    show_menu
    read -r -N1 char  # Read first character

    if [[ $char == $'\x1b' ]]; then  # ESC character for arrows
        read -r -N2 char # Read remaining 2 characters
        case $char in
            '[A')  # Up arrow key
                if (( current_index > 0 )); then
                    ((current_index--))
                fi
                ;;
            '[B')  # Down arrow key
                if (( current_index < ${#unique_paths[@]} - 1 )); then
                    ((current_index++))
                fi
                ;;
        esac
    elif [[ $char == "" ]]; then  # Enter key
        selected_path=${unique_paths[$current_index]}
        echo "$selected_path"
        break
    elif [[ $char == "q" || $char == "Q" ]]; then  # Quit key
        echo ""
        break
    fi
done
