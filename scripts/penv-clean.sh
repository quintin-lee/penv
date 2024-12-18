#!/usr/bin/bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source ${SCRIPT_DIR}/env.sh

pid_files=$(ls ${VENV_STORAGE_DIR}/*.pid 2>/dev/null)
activate_files=$(ls ${VENV_STORAGE_DIR}/*.activate 2>/dev/null)

parent_pid=$(ps -o ppid= -p $$)
parent_pid=$(echo $(ps -o ppid= -p $parent_pid) | cut -f2)

for file in $activate_files
do
    rm -f $file
done

for file in $pid_files
do
    pid=$(echo $(basename $file) | cut -d'.' -f 1)
    rm -f $file
    if [ "x"$pid = "x"$parent_pid ]
    then
        continue
    fi
    if ps -p ${pid} > /dev/null 2>&1
    then
        kill -9 $pid
    fi
done

if [ "x$CURRENT_ENV" != "x" ]
then
    kill -9 $parent_pid
fi
