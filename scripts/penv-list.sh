#!/usr/bin/bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source ${SCRIPT_DIR}/env.sh

# 初始化最大宽度
max_name_width=0
max_description_width=0

# 存储所有虚拟环境的名称和描述
declare -A names
declare -A descriptions

# 第一次遍历，确定每列的最大宽度
for name in $(ls ${VENV_STORAGE_DIR}/ 2>/dev/null)
do
    env_dir="${VENV_STORAGE_DIR}/${name}"
    description_file="${env_dir}/description.txt"
    
    if [ -f "${description_file}" ]; then
        description=$(cat "${description_file}")
    else
        description=""
    fi
    
    # 存储名称和描述
    names[$name]=$name
    descriptions[$name]=$description
    
    # 更新最大宽度
    name_length=${#name}
    description_length=${#description}
    
    if (( name_length > max_name_width )); then
        max_name_width=$name_length
    fi
    
    if (( description_length > max_description_width )); then
        max_description_width=$description_length
    fi
done

# 打印表头
printf "%-${max_name_width}s\t%-${max_description_width}s\n" "Name" "Description"
printf "%-${max_name_width}s\t%-${max_description_width}s\n" "----" "-----------"

# 第二次遍历，打印对齐的输出
for name in "${!names[@]}"
do
    description=${descriptions[$name]}
    printf "%-${max_name_width}s\t%-${max_description_width}s\n" "${name}" "${description}"
done
