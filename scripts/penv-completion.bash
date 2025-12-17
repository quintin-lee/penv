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
        # More reliable way to extract environment names
        local envs
        envs=$(timeout 3s "${COMP_WORDS[0]}" list 2>/dev/null | tail -n +4 | head -n -3 | awk '{print $1}' | grep -v "^$" | grep -v "^Name$")
        COMPREPLY=( $(compgen -W "${envs}" -- "${cur}") )
        return 0
    fi

    # Complete commands
    if [[ ${COMP_CWORD} -eq 1 ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
        return 0
    fi

    # Add options for 'list' command
    if [[ "${prev}" == "list" ]]; then
        local list_opts="--sort-by=name --sort-by=date --filter="
        COMPREPLY=( $(compgen -W "${list_opts}" -- "${cur}") )
        return 0
    fi
}

complete -F _penv_completion penv