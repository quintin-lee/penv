# penv — Python Virtual Environment Manager

[![Version](https://img.shields.io/badge/version-0.2.1-blue.svg)](https://github.com/quintin-lee/penv/releases)
[![License](https://img.shields.io/badge/license-GPL-green.svg)](LICENSE)
[![CI](https://github.com/quintin-lee/penv/actions/workflows/ci.yml/badge.svg)](https://github.com/quintin-lee/penv/actions/workflows/ci.yml)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-brightgreen)](https://github.com/quintin-lee/penv/actions/workflows/ci.yml)
[![Platform](https://img.shields.io/badge/platform-linux-lightgrey.svg)](https://github.com/quintin-lee/penv)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contributing)

**penv** is a command-line tool for managing Python virtual environments. It simplifies creation, activation, cloning, archiving, and cleanup of `venv` environments — all from the terminal with no extra Python dependencies.

```shell
# Quick start
penv create myproject "My Python project"
penv activate myproject       # spawns a sub-shell with venv active
pip install requests
penv deactivate
penv list                     # shows all environments
```

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
  - [Lifecycle](#lifecycle)
  - [Activation](#activation)
  - [Information](#information)
  - [Dependencies](#dependencies)
  - [Project Integration](#project-integration)
  - [Archive & Transfer](#archive--transfer)
  - [Maintenance](#maintenance)
- [Shell Completion](#shell-completion)
- [How It Works](#how-it-works)
- [Configuration](#configuration)
- [Development](#development)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- **36 commands** across 7 categories — full venv lifecycle management
- **JSON output** (`penv list --json`) — for IDE and script integration
- **Interactive pickers** — fuzzy-finder integration (`fzf`) for activate/remove
- **direnv integration** — auto-generate `.envrc` files for directory-based activation
- **Plugins** — extend penv with custom commands in `~/.config/penv/plugins/`
- **Self-upgrade** — `penv upgrade` fetches the latest release from GitHub
- **Environment archiving** — export/import whole environments as tarballs
- **Health diagnostics** — `penv doctor` checks everything from dependencies to stale markers
- **Automated cleanup** — `penv prune` removes broken environments
- **Shell completion** — bash, zsh, and fish
- **Systemd integration** — auto-clean stale activation markers
- **Python version selection** — interactive picker on `create`
- **CI/CD ready** — ShellCheck, 93+ bats tests, automated Release pipeline

---

## Installation

### Prerequisites

- **Python 3** with `venv` module (`python3 -m venv`)
- **expect** (required for `penv activate`)
- **coreutils** (`realpath`, `timeout`)

### Method 1: `penv init` (Recommended)

After adding penv to your PATH, run the initialization tool:

```shell
penv init
```

It detects your shell (bash/zsh/fish), installs completion, adds the auto-activation hook to your profile, enables the systemd service, creates the plugin directory, and generates a default config. Supports `--yes` for non-interactive mode.

### Method 2: Build Packages

```shell
# Build both ArchLinux and Debian packages
make

# ArchLinux only
make pkg

# Debian/Ubuntu only
make deb
```

### Method 3: ArchLinux PKGBUILD

```shell
bash tools/make_pkg.sh
sudo pacman -U penv-*.pkg.tar.zst
```

### Method 4: Debian/Ubuntu

```shell
bash tools/make_deb.sh
sudo dpkg -i penv_*.deb
```

### Method 5: Direct Install

```shell
git clone https://github.com/quintin-lee/penv.git
cd penv
sudo make install
```

### Upgrade

```shell
penv upgrade                      # self-update from GitHub Release
```

---

## Usage

All commands follow `penv <command> [arguments]`.

### Lifecycle

| Command | Description |
|---|---|
| `penv create <name> [desc]` | Create a virtual environment (with optional description) |
| `penv clone <src> <dst> [desc]` | Clone an environment, rewrite hardcoded paths |
| `penv remove <name>` | Remove an environment |
| `penv rename <old> <new>` | Rename and update all internal references |

```shell
penv create myproject "API service"
penv clone myproject myproject-backup
penv rename myproject myproject-v2
penv remove myproject-backup
```

### Activation

| Command | Description |
|---|---|
| `penv activate <name>` | Spawn a sub-shell with the environment active (fzf picker if name omitted) |
| `penv deactivate` | Decrement activation counter |
| `penv show` | Show which environments are currently active |
| `penv clean` | Deactivate all environments and clean up markers |

Activation spawns a **sub-shell**. Type `exit` to return to your original shell — this automatically triggers deactivation.

```shell
penv activate            # fzf interactive picker (if fzf installed)
penv activate myproject  # direct activation
penv show                # see active envs
penv deactivate          # deactivate one level
penv clean               # deactivate everything
```

### Information

| Command | Description |
|---|---|
| `penv list` | List all environments (sorted, filtered, or JSON) |
| `penv info <name>` | Detailed info: Python version, path, size, packages, activation status |
| `penv usage [--sort-by=size\|name]` | Disk usage report per environment |
| `penv tree <name>` | Package dependency tree |
| `penv doctor` | Full system health diagnostics |

```shell
penv list                       # formatted table
penv list --json                # machine-readable JSON
penv list --sort-by=date        # sort by creation date
penv list --filter=test         # filter by name pattern
penv info myproject             # detailed env info
penv usage --sort-by=name       # disk usage sorted alphabetically
penv tree myproject             # dependency tree
penv doctor                     # system health check
```

### Dependencies

| Command | Description |
|---|---|
| `penv requirements <name> export [file]` | Export pip packages (to env dir or file) |
| `penv requirements <name> import <file>` | Import pip packages from file |

```shell
penv requirements myproject export              # writes to env's own requirements.txt
penv requirements myproject export /path/to/file
penv requirements myproject import /path/to/file
```

### Project Integration

| Command | Description |
|---|---|
| `penv project bind <name> [--direnv]` | Bind current directory to an environment |
| `penv project unbind` | Remove binding |
| `penv project show` | Show binding for current directory |
| `penv project list` | List all bindings under `$HOME` |

```shell
cd /my/project
penv project bind myproject         # creates .penv file
penv project bind myproject --direnv  # generates .envrc + runs direnv allow
```

### Archive & Transfer

| Command | Description |
|---|---|
| `penv export <name> [file]` | Package environment as a gzipped tarball |
| `penv import <archive> [name]` | Restore environment from tarball |

```shell
penv export myproject myproject.tar.gz     # archive with metadata
penv import myproject.tar.gz               # restore, auto-paths fixed
penv import myproject.tar.gz newname       # restore with a different name
```

### Maintenance

| Command | Description |
|---|---|
| `penv config [list\|get\|set]` | Manage configuration (`~/.config/penv/config`) |
| `penv upgrade` | Self-update from GitHub Releases |
| `penv prune [--force]` | Remove broken environments |
| `penv plugin [list]` | List installed plugins |
| `penv init` | One-command initial setup (completion, profile, systemd, plugins) |

```shell
penv config set default_python python3.11
penv config list
penv upgrade                    # auto-detect git/system/custom install
penv prune --force              # remove broken envs without confirmation
penv plugin list                # ~/.config/penv/plugins/*.sh
```

---

## Shell Completion

penv provides completion for all major shells.

### Bash

```bash
source /path/to/penv/scripts/penv-completion.bash
```

### Zsh

```zsh
autoload -Uz compinit bashcompinit
compinit
bashcompinit
source /path/to/penv/scripts/penv-completion.bash
```

### Fish

```fish
cp /path/to/penv/scripts/penv-completion.fish ~/.config/fish/completions/
```

Or simply run `penv init` to install everything automatically.

---

## How It Works

```
┌──────────┐    dynamic dispatch      ┌──────────────────────┐
│  penv    │ ──► file exists? ──►     │ scripts/penv-*.sh   │
│ (entry)  │     yes: execute         │ (36 subcommand mods) │
└──────────┘     no:  plugin fallback └──────────┬───────────┘
        │           to PENV_PLUGIN_DIR/           │ source
        │                                         ▼
        │                                  ┌──────────────┐
        │                                  │  env.sh      │
        │                                  │  VENV_STORAGE│
        │                                  │  PENV_PLUGIN │
        │                                  │  config load │
        │                                  └──────────────┘
        │
        ▼
  ┌────────────────┐
  │ ~/.config/penv/│
  │  plugins/*.sh  │ ◄── custom commands auto-discovered
  └────────────────┘
```

### Key Concepts

- **Dynamic dispatch**: Any executable `scripts/penv-<name>.sh` automatically registers as a command. No hardcoded registrations.
- **Plugin system**: Place executable `.sh` files in `~/.config/penv/plugins/` — they become `penv <filename>` commands automatically.
- **Storage**: Environments live under `~/.cache/python-venv/` by default (configurable). Each is a standard Python `venv` directory.
- **Activation tracking**: Marker files (`<env>.activate`, `<pid>.pid`) track active sessions for safe multi-shell usage.
- **Activation flow**: `penv activate` uses `expect` to spawn a sub-shell that sources the venv's `activate` script. Exiting the sub-shell decrements the reference count and cleans up.
- **Config**: Key=value file at `~/.config/penv/config` loaded by `env.sh` on every invocation. Supports `storage_dir` and `default_python`.
- **Auto-cleanup**: Optional `penv.service` (systemd) runs every 60 seconds to clean stale activation markers.
- **Python version selection**: `select_version.sh` scans common paths and presents an interactive menu on `create`.

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|---|---|---|
| `VENV_STORAGE_DIR` | `~/.cache/python-venv` | Virtual environment storage directory |
| `PENV_PLUGIN_DIR` | `~/.config/penv/plugins` | Plugin directory |
| `PENV_DEFAULT_PYTHON` | *(system default)* | Default Python for `penv create` |

### Config File (`~/.config/penv/config`)

```ini
# Persistent configuration
default_python = python3.11
storage_dir = /custom/venv/path
```

Manage via `penv config`:

```shell
penv config list
penv config get default_python
penv config set default_python python3.11
```

---

## Development

### Project Structure

```
├── penv                               # Entry point — dynamic command dispatcher
├── VERSION                            # Single source of truth for version
├── Makefile                           # Build orchestration (pkg/deb/test/install)
├── scripts/
│   ├── env.sh                         # Shared env vars, die(), config loader
│   ├── penv-*.sh                      # 36 subcommand implementations
│   ├── activate.exp                   # Expect script for venv activation
│   ├── select_version.sh              # Interactive Python version picker
│   ├── auto-clean.sh                  # Periodic stale marker cleanup daemon
│   ├── penv-auto-activate.sh          # Shell profile integration
│   ├── penv-completion.bash           # Bash/Zsh completion
│   └── penv-completion.fish           # Fish completion
├── tests/
│   ├── setup.bash                     # Shared test helpers
│   └── penv_*.bats                   # 93+ bats test cases
├── tools/
│   ├── make_pkg.sh                    # ArchLinux package build
│   ├── make_deb.sh                    # Debian/Ubuntu package build
│   └── make_tag.sh                    # Annotated git tag creation
├── PKGBUILD                            # ArchLinux PKGBUILD
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                     # ShellCheck + bats on push/PR
│   │   └── release.yml                # Auto-build + publish on tag push
│   └── dependabot.yml
├── CHANGELOG.md
├── CONTRIBUTING.md
└── LICENSE                             # GPL v3
```

### Code Style

- `#!/usr/bin/env bash`
- Quote all variable expansions (`"$var"`)
- Validate input at every entry point
- Use `timeout` for operations that could hang
- Wrap errors with `die()` (prints to stderr, exits 1)
- All commands self-document via `--help`/`-h`

---

## Testing

The project uses [bats-core](https://github.com/bats-core/bats-core) for testing:

```shell
# Run all tests
make test

# Run with shellcheck only
make test-shellcheck

# Run specific test file
npx bats tests/penv_create.bats
```

Tests are run automatically in CI (ShellCheck + bats on every push and PR).

---

## Troubleshooting

### `penv: command not found`

Ensure penv is in your `PATH`:

```shell
which penv
# → /usr/local/bin/penv
```

### `penv doctor` shows failures

Run diagnostics for a full system check:

```shell
penv doctor
```

Common issues:
- **expect not installed**: Install via your package manager (`apt install expect`, `pacman -S expect`)
- **VENV_STORAGE_DIR not writable**: Check permissions or set a custom path via `penv config set storage_dir`
- **Stale activation markers**: Run `penv clean` or `penv prune`

### No response after activation

The sub-shell is waiting for input — type `exit` or `penv deactivate` to return.

### Broken environment

```shell
penv doctor                          # identify broken envs
penv prune                           # remove them interactively
penv prune --force                   # remove without confirmation
```

### Need more help

[Open an issue](https://github.com/quintin-lee/penv/issues) with steps to reproduce and `penv doctor` output.

---

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines. Key points:

- **Bug reports**: Open an issue with steps to reproduce
- **Feature requests**: Open an issue describing your idea
- **Code changes**: Fork → feature branch → PR
- **Documentation**: Corrections and clarifications appreciated

The project follows [Conventional Commits](https://www.conventionalcommits.org/) and all code must pass ShellCheck (`--severity=warning`) and the bats test suite.

---

## License

GNU General Public License v3.0 — see [LICENSE](LICENSE) for details.

---

## Version History

| Version | Date | Highlights |
|---|---|---|
| **0.2.0** | 2026-07-16 | 15 new commands (init/info/config/rename/doc/prune/plugin/tree/export/import/upgrade), direnv+fzf integration, Release CI, dynamic dispatch, fish completion, self-documenting `--help`, 93 bats tests |
| **0.1.2** | 2025-12-17 | clone, requirements, project, usage; security hardening; VERSION unification; ShellCheck CI; die() error handling |
| **0.1.1** | 2025-09-01 | bash completion, `--version`, sorting/filtering improvements |
| **0.1.0** | 2024 | Initial release — create, list, remove, activate, deactivate, clean |

See [CHANGELOG.md](CHANGELOG.md) for the complete version history.
