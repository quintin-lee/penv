# penv completion for fish shell
# Source this file or copy to ~/.config/fish/completions/penv.fish
#
# Install:
#   cp scripts/penv-completion.fish ~/.config/fish/completions/penv.fish

function __penv_list_envs
    set -l storage_dir $VENV_STORAGE_DIR
    if test -z "$storage_dir"
        set storage_dir "$HOME/.cache/python-venv"
    end
    if test -d "$storage_dir"
        command ls -1 "$storage_dir" 2>/dev/null | grep -v '\.\(activate\|pid\)$'
    end
end

# All penv commands
set -l penv_commands \
    create list remove activate deactivate show clean \
    clone requirements project usage info config rename \
    help --version

# Commands that take an environment name
set -l env_commands \
    create activate remove clone info requirements

# Main completion: penv <tab> → list commands
complete -c penv -f -n "not __fish_seen_subcommand_from $penv_commands" \
    -a "create"    -d "Create a new virtual environment"
complete -c penv -f -n "not __fish_seen_subcommand_from $penv_commands" \
    -a "list"      -d "List all virtual environments"
complete -c penv -f -n "not __fish_seen_subcommand_from $penv_commands" \
    -a "remove"    -d "Remove a virtual environment"
complete -c penv -f -n "not __fish_seen_subcommand_from $penv_commands" \
    -a "activate"  -d "Activate a virtual environment"
complete -c penv -f -n "not __fish_seen_subcommand_from $penv_commands" \
    -a "deactivate" -d "Deactivate the current virtual environment"
complete -c penv -f -n "not __fish_seen_subcommand_from $penv_commands" \
    -a "show"      -d "Show active virtual environments"
complete -c penv -f -n "not __fish_seen_subcommand_from $penv_commands" \
    -a "clean"     -d "Deactivate all virtual environments"
complete -c penv -f -n "not __fish_seen_subcommand_from $penv_commands" \
    -a "clone"     -d "Clone a virtual environment"
complete -c penv -f -n "not __fish_seen_subcommand_from $penv_commands" \
    -a "requirements" -d "Export or import requirements"
complete -c penv -f -n "not __fish_seen_subcommand_from $penv_commands" \
    -a "project"   -d "Manage project bindings"
complete -c penv -f -n "not __fish_seen_subcommand_from $penv_commands" \
    -a "usage"     -d "Show disk usage"
complete -c penv -f -n "not __fish_seen_subcommand_from $penv_commands" \
    -a "info"      -d "Show environment details"
complete -c penv -f -n "not __fish_seen_subcommand_from $penv_commands" \
    -a "config"    -d "Manage configuration"
complete -c penv -f -n "not __fish_seen_subcommand_from $penv_commands" \
    -a "rename"    -d "Rename a virtual environment"
complete -c penv -f -n "not __fish_seen_subcommand_from $penv_commands" \
    -a "help"      -d "Show help for a command"
complete -c penv -f -n "not __fish_seen_subcommand_from $penv_commands" \
    -a "--version" -d "Show version information"

# penv <tab> after a command → complete env names
for cmd in $env_commands
    complete -c penv -f -n "__fish_seen_subcommand_from $cmd" \
        -a "(__penv_list_envs)"
end

# penv list options
complete -c penv -f -n "__fish_seen_subcommand_from list" \
    -l sort-by -d "Sort by" -xa "name date"
complete -c penv -f -n "__fish_seen_subcommand_from list" \
    -l filter -d "Filter by pattern"

# penv usage options
complete -c penv -f -n "__fish_seen_subcommand_from usage" \
    -l sort-by -d "Sort by" -xa "size name"

# penv config subcommands
complete -c penv -f -n "__fish_seen_subcommand_from config; and not __fish_seen_subcommand_from list get set" \
    -a "list"   -d "List all configuration"
complete -c penv -f -n "__fish_seen_subcommand_from config; and not __fish_seen_subcommand_from list get set" \
    -a "get"    -d "Get a configuration value"
complete -c penv -f -n "__fish_seen_subcommand_from config; and not __fish_seen_subcommand_from list get set" \
    -a "set"    -d "Set a configuration value"

# penv project subcommands
complete -c penv -f -n "__fish_seen_subcommand_from project; and not __fish_seen_subcommand_from bind unbind show list" \
    -a "bind"   -d "Bind current directory to an environment"
complete -c penv -f -n "__fish_seen_subcommand_from project; and not __fish_seen_subcommand_from bind unbind show list" \
    -a "unbind" -d "Unbind current directory"
complete -c penv -f -n "__fish_seen_subcommand_from project; and not __fish_seen_subcommand_from bind unbind show list" \
    -a "show"   -d "Show current binding"
complete -c penv -f -n "__fish_seen_subcommand_from project; and not __fish_seen_subcommand_from bind unbind show list" \
    -a "list"   -d "List all bindings"

# penv requirements subcommands
complete -c penv -f -n "__fish_seen_subcommand_from requirements" \
    -a "export import"
