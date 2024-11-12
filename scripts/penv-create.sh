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

# 如果虚拟环境不存在，可以在这里添加创建虚拟环境的代码
# 例如，使用 virtualenv 创建虚拟环境
echo "Creating virtual environment '$virtual_env_name'..."
# 这里可以放置创建虚拟环境的命令

python -m venv ${VENV_STORAGE_DIR}/$virtual_env_name

echo "Virtual environment '$virtual_env_name' created successfully."
echo "$description" > "${VENV_STORAGE_DIR}/$virtual_env_name/description.txt"
