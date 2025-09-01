#!/usr/bin/env bash

all_real_paths=()

# 函数：获取实体文件路径
get_real_path() {
    local file=$1
    if [[ -L "$file" ]]; then
        # 读取软链接指向的实体文件路径
        readlink -f "$file"
    else
        echo "$file"
    fi
}

# 函数：打印Python版本
print_python_version() {
    local python_executable=$1
    if [[ -x "$python_executable" ]]; then
        echo "Python $(eval "$python_executable" --version | cut -d' ' -f2)"
    fi
}

# 检查常见的Python可执行文件路径
common_paths=(/usr/bin /usr/local/bin /opt $HOME/.local/bin)

# 使用find命令查找所有Python可执行文件
# 注意：这可能需要一些时间，取决于文件系统的规模
for path in "${common_paths[@]}"; do
    while IFS= read -r executable; do
        # 检查文件是否可执行
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

# 去除重复的实体文件路径
#unique_paths=$(echo "${all_real_paths[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
unique_paths=($(printf "%s\n" "${all_real_paths[@]}" | sort -u))

# 显示菜单并允许用户选择
show_menu() {
    clear
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

# 初始选择索引
current_index=0

# 主循环
while true; do
    show_menu
    read -rsn1 input

    case "$input" in
        A)  # Up arrow key
            if (( current_index > 0 )); then
                ((current_index--))
            fi
            ;;
        B)  # Down arrow key
            if (( current_index < ${#unique_paths[@]} - 1 )); then
                ((current_index++))
            fi
            ;;
        "") # Enter key
            selected_path=${unique_paths[$current_index]}
            echo "$selected_path"
            break
            ;;
        q|Q) # Quit key
            echo ""
            break
            ;;
    esac
done
