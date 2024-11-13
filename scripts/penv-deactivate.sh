#!/usr/bin/bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source ${SCRIPT_DIR}/env.sh

# 使用 ps 命令获取父进程的 PID
parent_pid=$(ps -o ppid= -p $$)
parent_pid=$(echo $(ps -o ppid= -p $parent_pid) | cut -f2)

if [ "x$CURRENT_ENV" != "x" ]
then
    file=${VENV_STORAGE_DIR}/${CURRENT_ENV}.activate
    if [ -f "${file}" ]
    then
        num=$(cat $file)
        num=$(($num - 1))
        if [ $num -eq 0 ]
        then
            rm -f $file
        else
            echo "$num" > $file
        fi
    fi

    pid_file=${VENV_STORAGE_DIR}/${parent_pid}.pid
    # pid 文件
    if [ -f "${pid_file}" ]
    then
        rm -f ${VENV_STORAGE_DIR}/${parent_pid}.pid
        kill -9 $parent_pid
    fi
else
    exit 1
fi

