# Python3 venv Management

A command-line tool for managing Python virtual environments that simplifies the creation, activation, deletion and other operations of virtual environments.

## Installation

### Method 1: Install from Release Page

1. Visit [Releases page](https://github.com/quintin-lee/penv/releases)
2. Download the latest version suitable for your system
3. Install it following the provided instructions

### Method 2: ArchLinux/Manjaro Package Installation

```shell
bash tools/make_pkg.sh
```

### Method 3: Debian/Ubuntu Package Installation

```shell
# sudo password is required during execution
bash tools/make_deb.sh
```

### Method 4: Direct Use of Source Code

1. Clone or download this repository
2. Add the [penv](file:///home/quintin/workspace/source/shell/python-venv/penv) script to your PATH, or run it directly with `./penv`

### Enable Command Completion

To enable command completion for bash, add the following line to your `~/.bashrc`:

```bash
source /path/to/penv/scripts/penv-completion.bash
```

Replace `/path/to/penv` with the actual path to your penv installation.

For zsh users, add the following to your `~/.zshrc`:

```bash
autoload -Uz compinit bashcompinit
compinit
bashcompinit
source /path/to/penv/scripts/penv-completion.bash
```

## Usage

```shell
Usage: penv cmd [params]

Python virtual environment management tool.

Commands:
  create        Creates a new virtual environment.
                Usage: penv create <env_name> [description]
  list          Lists all virtual environments.
                Usage: penv list [--sort-by=name|date] [--filter=pattern]
  remove        Removes a virtual environment.
                Usage: penv remove <env_name>
  activate      Activates a virtual environment.
                Usage: penv activate <env_name>
  show          Show active virtual environments.
                Usage: penv show
  deactivate    Deactivates the current virtual environment.
                Usage: penv deactivate
  clean         Deactivates all virtual environments.
                Usage: penv clean
  clone         Clones a virtual environment to a new one.
                Usage: penv clone <source_env> <dest_env> [description]
  requirements  Export/import requirements for an environment.
                Usage: penv requirements <env_name> <export|import> [file]
  project       Bind projects to virtual environments.
                Usage: penv project <bind|unbind|show|list>
  usage         Show disk usage of virtual environments.
                Usage: penv usage [--sort-by=size|name]
  help, -h, --help    Displays this help message.
                Usage: penv help [command]
  --version     Display version information.

Examples:
  penv create myproject "My Python project"
  penv list
  penv list --sort-by=date
  penv activate myproject
  penv deactivate
  penv remove myproject
  penv clone myproject newproject "New project based on myproject"
  penv requirements myproject export requirements.txt
  penv requirements myproject import requirements.txt
  penv project bind myproject
  penv usage --sort-by=size
```

## Usage Examples

### Create a Virtual Environment

```shell
# Create a virtual environment named myproject
penv create myproject

# Create a virtual environment with description
penv create myproject "My Python project"
```

### List All Virtual Environments

```shell
penv list

# List environments sorted by creation date
penv list --sort-by=date

# List environments matching a pattern
penv list --filter=test
```

### Activate a Virtual Environment

```shell
penv activate myproject
```

### Show Currently Activated Virtual Environment

```shell
penv show
```

### Deactivate Current Virtual Environment

```shell
penv deactivate
```

### Remove a Virtual Environment

```shell
penv remove myproject
```

### Deactivate All Virtual Environments

```shell
penv clean
```

### Get Help for Specific Commands

```shell
penv help create
penv help list
penv help remove
```

### Clone a Virtual Environment

```shell
# Clone an existing environment to a new one
penv clone myproject newproject

# Clone with a description
penv clone myproject newproject "New project based on myproject"
```

### Manage Requirements

```shell
# Export packages from an environment to requirements.txt
penv requirements myproject export requirements.txt

# Import packages from requirements.txt to an environment
penv requirements myproject import requirements.txt

# Export to a specific file
penv requirements myproject export myproject-requirements.txt
```

### Project Binding

```shell
# Bind current directory to an environment
cd /path/to/my/project
penv project bind myproject

# Show current directory binding
penv project show

# Unbind current directory
penv project unbind

# List all project bindings
penv project list
```

### Auto-activation Setup

To enable auto-activation when you `cd` into a project directory, add this to your `~/.bashrc` or `~/.zshrc`:

```bash
source /path/to/penv/scripts/penv-auto-activate.sh
```

Then you can use the `penv_auto_activate` function or override `cd` (see comments in the script).

### View Disk Usage

```shell
# Show disk usage of all environments
penv usage

# Show environments sorted by name
penv usage --sort-by=name
```

## Troubleshooting Guide

### 1. Permission Issues

If you encounter permission issues during installation or usage, ensure:
- You have read and write permissions to the virtual environment storage directory (default is `~/.cache/python-venv`)
- sudo permissions may be required when packaging deb files

### 2. Command Not Found

If you get `penv: command not found`:
- Ensure the [penv](file:///home/quintin/workspace/source/shell/python-venv/penv) script is in your PATH
- Or execute with relative path: `./penv`

### 3. Virtual Environment Creation Failed

If virtual environment creation fails:
- Check if Python3 and venv module are installed
- Ensure the system has sufficient disk space

### 4. No Response After Activating Environment

If there is no response after activating a virtual environment:
- You can use `penv deactivate` or `penv clean` to deactivate the environment
- Check if system resources are sufficient

### 5. Other Issues

If you encounter other issues:
1. Check the [Issues](https://github.com/quintin-lee/penv/issues) page for similar issues
2. If not, please submit a new issue describing the problem you encountered

## Version History

### Current Version
**0.1.2** - Released on 2025-12-17
- Enhanced security with improved input validation
- Better performance with optimized file operations
- Improved stability with better error handling
- Enhanced terminal compatibility
- Standardized for better cross-platform support

See [CHANGELOG.md](CHANGELOG.md) for complete version change history.
