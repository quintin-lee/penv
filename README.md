# Python3 venv Management

[![Version](https://img.shields.io/badge/version-0.1.2-blue.svg)](https://github.com/quintin-lee/penv/releases)
[![License](https://img.shields.io/badge/license-GPL-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-linux-lightgrey.svg)](https://github.com/quintin-lee/penv)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contributing)

**penv** is a command-line tool for managing Python virtual environments. It simplifies the creation, activation, deletion, cloning, and other operations of Python `venv` environments — all from the terminal, with no extra dependencies beyond Python 3 and bash.

---

## Table of Contents

- [Quick Start](#quick-start)
- [Installation](#installation)
- [Usage](#usage)
  - [Command Overview](#command-overview)
  - [Managing Environments](#managing-environments)
  - [Project Binding & Auto-activation](#project-binding--auto-activation)
  - [Disk Usage](#disk-usage)
- [How It Works](#how-it-works)
- [Configuration](#configuration)
- [Development](#development)
- [Contributing](#contributing)
- [Troubleshooting](#troubleshooting)
- [License](#license)

---

## Quick Start

```shell
# Create an environment
penv create myproject "My Python project"

# Activate it
penv activate myproject

# List all environments
penv list

# Install packages, run code...
pip install requests
python my_script.py

# Deactivate when done
penv deactivate
```

All environments are stored under `~/.cache/python-venv/` by default.

---

## Installation

### Method 1: ArchLinux / Manjaro (AUR-style PKGBUILD)

```shell
bash tools/make_pkg.sh
```

This creates an installable `.pkg.tar.zst` package. Install it with:

```shell
sudo pacman -U penv-*.pkg.tar.zst
```

### Method 2: Debian / Ubuntu

```shell
# sudo password is required during execution
bash tools/make_deb.sh
```

The `.deb` package will be generated in the project root.

### Method 3: Direct Installation

```shell
# Clone the repo
git clone https://github.com/quintin-lee/penv.git
cd penv

# Add to PATH (temporary)
export PATH="$PWD:$PATH"

# Or install to a system location
sudo cp penv /usr/local/bin/
sudo cp -r scripts /usr/local/penv/
```

### Method 4: Download Release

1. Visit the [Releases page](https://github.com/quintin-lee/penv/releases)
2. Download the latest version for your system
3. Extract and add the `penv` script to your `PATH`

---

## Usage

### Command Overview

| Command | Description |
|---|---|
| `penv create <name> [desc]` | Create a new virtual environment |
| `penv list [--sort-by=name\|date] [--filter=pattern]` | List all virtual environments |
| `penv remove <name>` | Remove a virtual environment |
| `penv activate <name>` | Activate a virtual environment |
| `penv deactivate` | Deactivate the current environment |
| `penv show` | Show active environments |
| `penv clean` | Deactivate all environments |
| `penv clone <src> <dst> [desc]` | Clone an environment |
| `penv requirements <name> <export\|import> [file]` | Export/import pip packages |
| `penv project <bind\|unbind\|show\|list>` | Bind projects to environments |
| `penv usage [--sort-by=size\|name]` | Show disk usage |
| `penv help [command]` | Show help for a specific command |
| `penv --version` | Show version |

### Managing Environments

#### Create

```shell
penv create myproject
penv create myproject "My Python project"  # with description
```

During creation, you will be prompted to select a Python version if multiple are detected.

#### List

```shell
penv list
penv list --sort-by=date                    # sort by creation date
penv list --filter=test                     # filter by name pattern
```

Active environments are highlighted in **green**.

#### Activate / Deactivate

```shell
penv activate myproject    # spawns a new shell with the environment active
penv deactivate            # decrements the activation counter
penv show                  # show which environments are active
penv clean                 # deactivate everything and clean up
```

> Note: `penv activate` spawns a **sub-shell** with the virtual environment activated. Type `exit` to return to your original shell — this automatically deactivates the environment.

#### Clone

```shell
penv clone myproject newproject
penv clone myproject newproject "New project based on myproject"
```

Hardcoded paths in the cloned environment's `bin/` directory are automatically rewritten.

#### Remove

```shell
penv remove myproject
```

A safety check ensures removal only happens within the expected storage directory.

#### Requirements

```shell
penv requirements myproject export              # writes to environment's own requirements.txt
penv requirements myproject export /path/to/file
penv requirements myproject import /path/to/file
```

### Project Binding & Auto-activation

Project binding links a directory to a virtual environment, enabling directory-based auto-activation.

#### Bind a Project

```shell
cd /path/to/my/project
penv project bind myproject        # creates a .penv file
```

#### Show / Unbind

```shell
penv project show                  # show binding for current directory
penv project unbind                # remove binding
penv project list                  # list all bindings under $HOME
```

#### Enable Auto-activation

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
source /path/to/penv/scripts/penv-auto-activate.sh

# Then manually activate:
cd /path/to/my/project
penv_auto_activate

# Or for automatic activation on cd, uncomment the cd() override in the script:
# cd() { _penv_cd_hook "$@"; }
```

### Enable Command Completion

#### Bash

```bash
# Add to ~/.bashrc:
source /path/to/penv/scripts/penv-completion.bash
```

#### Zsh

```zsh
# Add to ~/.zshrc:
autoload -Uz compinit bashcompinit
compinit
bashcompinit
source /path/to/penv/scripts/penv-completion.bash
```

### Disk Usage

```shell
penv usage                          # sorted by size (largest first)
penv usage --sort-by=name           # sorted alphabetically
```

---

## How It Works

```
┌──────────┐    command dispatch     ┌──────────────────────┐
│  penv    │ ──────────────────────►  │ scripts/penv-*.sh   │
│ (entry)  │                         │ (subcommand modules) │
└──────────┘                         └──────────┬───────────┘
                                                │ source
                                                ▼
                                        ┌──────────────┐
                                        │  env.sh      │
                                        │  VENV_STORAGE │
                                        └──────────────┘
```

### Key Concepts

- **Storage**: All environments are stored in `~/.cache/python-venv/`. Each environment is a standard Python venv directory.

- **Activation Tracking**: When activated, two marker files are created:
  - `<env_name>.activate` — reference count for the environment (supports multiple shells)
  - `<pid>.pid` — shell process ID for cleanup

- **Activation Flow**: `penv activate` uses `expect` to spawn a sub-shell, `source` the venv's `activate` script, and enter interactive mode. When you `exit` the sub-shell, the reference count is decremented.

- **Auto-cleanup**: A systemd service (`penv.service`) runs `auto-clean.sh` every 60 seconds to clean up stale activation markers.

- **Python Version Selection**: On `create`, `select_version.sh` scans common paths (`/usr/bin`, `/usr/local/bin`, `/opt`, `~/.local/bin`) for Python executables and presents an interactive menu.

---

## Configuration

| Variable | Default | Description |
|---|---|---|
| `VENV_STORAGE_DIR` | `~/.cache/python-venv` | Directory where virtual environments are stored |

Override by exporting before running commands:

```shell
export VENV_STORAGE_DIR="/path/to/custom/dir"
penv create myproject
```

---

## Development

### Prerequisites

- Bash 4.0+
- Python 3
- `expect` (for activate command)
- `coreutils` (for `realpath`, `timeout`)

### Project Structure

```
├── penv                          # Entry point — command dispatcher
├── scripts/                      # Subcommand implementations
│   ├── env.sh                    # Shared environment configuration
│   ├── penv-create.sh            # Create virtual environment
│   ├── penv-list.sh              # List environments
│   ├── penv-remove.sh            # Remove environment
│   ├── penv-activate.sh          # Activate (delegates to expect)
│   ├── penv-deactivate.sh        # Deactivate
│   ├── penv-show.sh              # Show active environments
│   ├── penv-clean.sh             # Clean all active environments
│   ├── penv-clone.sh             # Clone environment
│   ├── penv-requirements.sh      # Export/import requirements
│   ├── penv-project.sh           # Project binding
│   ├── penv-usage.sh             # Disk usage report
│   ├── penv-auto-activate.sh     # Shell integration for auto-activation
│   ├── penv-completion.bash      # Bash completion
│   ├── activate.exp              # Expect script for activation
│   ├── select_version.sh         # Interactive Python version picker
│   ├── auto-clean.sh             # Periodic cleanup daemon
│   └── penv.service              # systemd service unit
├── tools/
│   ├── make_pkg.sh               # ArchLinux package build
│   └── make_deb.sh               # Debian/Ubuntu package build
└── PKGBUILD                      # ArchLinux PKGBUILD
```

### Code Style

- All scripts use `#!/usr/bin/env bash`
- Variable naming: `UPPER_CASE_WITH_UNDERSCORES` for globals and constants
- Functions: `lower_case_with_underscores`
- Always quote variable expansions (`"$var"` not `$var`)
- Validate input at every entry point
- Use `timeout` for any operation that could hang

### Making Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Test manually with `bash -x penv <command>` for debugging
5. Submit a Pull Request

---

## Contributing

Contributions are welcome! Here's how you can help:

- **Report bugs**: Open an [issue](https://github.com/quintin-lee/penv/issues) with details about the problem
- **Suggest features**: Open an issue describing your idea
- **Submit code changes**: Fork the repo and submit a Pull Request
- **Improve documentation**: Corrections and clarifications are always appreciated

### Guidelines

- Keep scripts POSIX-compatible where possible (but bash extensions are acceptable)
- Maintain the existing code style and conventions
- Ensure backward compatibility — avoid breaking existing commands
- Test your changes on a clean system if possible

---

## Troubleshooting

### 1. Permission Issues

Ensure you have read and write permissions to `VENV_STORAGE_DIR` (default `~/.cache/python-venv`). Sudo may be needed when packaging `.deb` files.

### 2. Command Not Found

- Ensure `penv` is in your `PATH`, or run with `./penv`
- After installing via package manager, restart your shell

### 3. Virtual Environment Creation Failed

- Check that `python3` and the `venv` module are installed:
  ```shell
  python3 -m venv --help
  ```
- Ensure sufficient disk space

### 4. No Response After Activation

- `penv deactivate` or `penv clean` to reset
- Check if the sub-shell is waiting for input (type `exit`)

### 5. Auto-activation Not Working

- Ensure `penv-auto-activate.sh` is sourced in your shell profile
- Verify a `.penv` file exists in the project directory
- Check that the bound environment still exists

### 6. Other Issues

- Check the [Issues](https://github.com/quintin-lee/penv/issues) page for similar reports
- If not found, submit a new issue describing your problem, steps to reproduce, and system information

---

## License

This project is licensed under the GNU General Public License — see the [LICENSE](LICENSE) file for details.

---

## Version History

| Version | Date | Highlights |
|---|---|---|
| **0.1.2** | 2025-12-17 | clone, requirements, project, usage commands; security hardening; performance optimizations |
| **0.1.1** | 2025-09-01 | bash completion, `--version`, sorting/filtering, error handling improvements |
| **0.1.0** | 2024 | Initial release — create, list, remove, activate, deactivate, clean |

See [CHANGELOG.md](CHANGELOG.md) for the complete version history.
