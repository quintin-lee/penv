#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source ${SCRIPT_DIR}/env.sh

# Use ps command to get the parent process PID
PARENT_PID=$(ps -o ppid= -p $$)
PARENT_PID=$(echo $(ps -o ppid= -p $PARENT_PID) | cut -f2)

if [ "x$CURRENT_ENV" != "x" ]
then
    FILE=${VENV_STORAGE_DIR}/${CURRENT_ENV}.activate
    if [ -f "${FILE}" ]
    then
        NUM=$(cat $FILE)
        NUM=$(($NUM - 1))
        if [ $NUM -eq 0 ]
        then
            rm -f $FILE
        else
            echo "$NUM" > $FILE
        fi
    fi

    PID_FILE=${VENV_STORAGE_DIR}/${PARENT_PID}.pid
    # pid file
    if [ -f "${PID_FILE}" ]
    then
        rm -f ${VENV_STORAGE_DIR}/${PARENT_PID}.pid
        kill -9 $PARENT_PID
    fi
else
    exit 1
fi