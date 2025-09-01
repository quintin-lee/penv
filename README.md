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

## Usage

```shell
Usage: penv cmd [params]

Python virtual environment management tool.

Commands:
  create        Creates a new virtual environment.
                Usage: penv create <env_name> [description]
  list          Lists all virtual environments.
                Usage: penv list
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
  help, -h, --help    Displays this help message.
  --version     Display version information.

Examples:
  penv create myproject "My Python project"
  penv list
  penv activate myproject
  penv deactivate
  penv remove myproject
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

See [CHANGELOG.md](file:///home/quintin/workspace/source/shell/python-venv/CHANGELOG.md) for version change history.