#!/usr/bin/bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source ${SCRIPT_DIR}/env.sh

# 初始化最大宽度
max_name_width=0
max_description_width=0
max_version_width=20

# 存储所有虚拟环境的名称和描述
declare -A names
declare -A descriptions

# 第一次遍历，确定每列的最大宽度
for name in $(ls ${VENV_STORAGE_DIR}/ 2>/dev/null)
do
    env_dir="${VENV_STORAGE_DIR}/${name}"
    description_file="${env_dir}/description.txt"

    if [ ! -d "$env_dir" ]
    then
        continue
    fi
    
    if [ -f "${description_file}" ]; then
        description=$(cat "${description_file}")
    else
        description=""
    fi
    
    # 存储名称和描述
    names[$name]=$name
    descriptions[$name]=$description
    
    # 更新最大宽度
    name_length=$(echo -n ${name} | wc -L)
    #description_length=${#description}
    description_length=$(echo -n ${description} | wc -L)
    
    if (( name_length > max_name_width )); then
        max_name_width=$name_length
    fi
    
    if (( description_length > max_description_width )); then
        max_description_width=$description_length
    fi
done

# 打印表头
printf "%-${max_name_width}s    %-${max_description_width}s    %-${max_version_width}s\n" "Name" "Description" "Python Version"
printf "%-${max_name_width}s    %-${max_description_width}s    %-${max_version_width}s\n" "----" "-----------" "--------------"

# 第二次遍历，打印对齐的输出
for name in "${!names[@]}"
do
    version=$(${VENV_STORAGE_DIR}/$name/bin/python --version | cut -d' ' -f2)
    description=${descriptions[$name]}
    printf "%-${max_name_width}s    %-${max_description_width}s    %-${max_version_width}s\n" "${name}" "${description}" "${version}"
done
