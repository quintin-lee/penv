#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source ${SCRIPT_DIR}/env.sh

PID_FILES=$(ls ${VENV_STORAGE_DIR}/*.pid 2>/dev/null)
ACTIVATE_FILES=$(ls ${VENV_STORAGE_DIR}/*.activate 2>/dev/null)

PARENT_PID=$(ps -o ppid= -p $$)
PARENT_PID=$(echo $(ps -o ppid= -p $PARENT_PID) | cut -f2)

for file in $ACTIVATE_FILES
do
    rm -f $file
done

for file in $PID_FILES
do
    PID=$(echo $(basename $file) | cut -d'.' -f 1)
    rm -f $file
    if [ "x"$PID = "x"$PARENT_PID ]
    then
        continue
    fi
    if ps -p ${PID} > /dev/null 2>&1
    then
        kill -9 $PID
    fi
done

if [ "x$CURRENT_ENV" != "x" ]
then
    kill -9 $PARENT_PID
fi