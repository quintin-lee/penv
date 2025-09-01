#!/usr/bin/env bash
# penv completion for bash

_penv_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="create list remove activate show deactivate clean help --help -h --version"

    # Get list of existing environments for relevant commands
    if [[ "${prev}" == "activate" || "${prev}" == "remove" ]]; then
        local envs=$(${COMP_WORDS[0]} list 2>/dev/null | awk 'NR>2 {print $1}' | grep -v "^$")
        COMPREPLY=( $(compgen -W "${envs}" -- ${cur}) )
        return 0
    fi

    # Complete commands
    if [[ ${COMP_CWORD} -eq 1 ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
}

complete -F _penv_completion penv