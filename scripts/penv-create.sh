#!/usr/bin/bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source ${SCRIPT_DIR}/env.sh

if [ ! -d "${VENV_STORAGE_DIR}" ]; then
    mkdir -p ${VENV_STORAGE_DIR}
fi

if [ $# -lt 2 ]; then
    echo "Error: No virtual environment name or description provided."
    echo "Usage: $0 <virtual_env_name> <description>"
    exit 1
fi

all_args=("$@")

# 虚拟环境名称
virtual_env_name=${all_args[0]}
# 描述信息
description="${all_args[1]}"

# 检查虚拟环境是否存在
if [ -d "${VENV_STORAGE_DIR}/$virtual_env_name" ]; then
    echo "Error: Virtual environment '$virtual_env_name' already exists."
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "Error: Python3 is not installed."
    exit 1
fi

selected_python=""
# 调用 select_python_version.sh 脚本并捕获输出
while IF= read line
do
    if [[ -f ${line} ]]
    then
        selected_python=$line
        continue
    fi
    if [[ -n $(echo ${line} | grep ':' | grep -v '^-') ]]
    then
        echo "   ${line}"
        continue
    fi
    echo "$line"
done < <(${SCRIPT_DIR}/select_version.sh)

# 检查是否有选中的 Python 版本
if [[ -n "$selected_python" ]]; then
    cmd=$selected_python
    # 可以在这里继续处理选中的 Python 版本
else
    cmd="python3"
fi

echo "Creating virtual environment '$virtual_env_name'..."
# 这里可以放置创建虚拟环境的命令
$cmd -m venv ${VENV_STORAGE_DIR}/$virtual_env_name

echo "Virtual environment '$virtual_env_name' created successfully."
echo "$description" > "${VENV_STORAGE_DIR}/$virtual_env_name/description.txt"
