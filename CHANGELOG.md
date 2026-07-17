# Changelog

All notable changes to penv will be documented in this file.

## [Unreleased]

### Added

### Changed

### Fixed

## [0.2.1] - 2026-07-17

### Added

- `penv list --json` — machine-readable JSON output with env details, total count, storage path, and currently active env
- `penv init [--yes]` — one-command setup with shell completion, profile hook, systemd service, plugin directory, and default config

### Changed

- `penv help` output now groups commands into categories (Lifecycle, Activation, Information, Dependencies, Project, Archive, Maintenance)
- `penv list` usage updated to show `--json` option
- `penv` command dispatch is now dynamic: any executable `scripts/penv-<cmd>.sh` is automatically available as `penv <cmd>` — no case pattern registration required
- `penv help` for script-backed commands is also dynamic: automatically forwards to `<cmd> --help`

### Fixed

- `/tmp` hardcoded temp file replaced with `mktemp` in `penv create`
- pip errors no longer silenced (`2>/dev/null` removed from `penv requirements`)
- `CURRENT_ENV` self-assignment replaced with proper `.activate` marker parsing in `penv show`
- Unbounded `find` limited with `-maxdepth 3` in `penv project list`

## [0.2.0] - 2026-07-16

### Added

#### New Commands (15)
- `penv info <env>` — detailed information about a virtual environment (Python version, path, disk usage, package count, activation status)
- `penv config [list|get|set]` — manage penv configuration (`default_python`, `storage_dir`)
- `penv rename <old> <new>` — rename a virtual environment, auto-fixes hardcoded paths, activation markers, and project bindings
- `penv doctor` — system health diagnostics (python3/expect/git dependencies, storage permissions, stale markers, environment integrity, shell completion, systemd service, config file)
- `penv prune [--force]` — scan for broken environments (missing `python`/`pyvenv.cfg`/`activate`) and remove with optional force flag
- `penv plugin [list]` — list installed plugins from `~/.config/penv/plugins/`
- `penv tree <env>` — show package dependency tree (prefers `pipdeptree`, falls back to flat `pip list`)
- `penv export <env> [file]` — archive an environment as a gzipped tarball with metadata (`PENV_META`) and sha256sum
- `penv import <archive> [name]` — restore an environment from tarball, auto-fixes hardcoded paths, validates environment integrity
- `penv upgrade` — self-update from GitHub Releases; detects install type (git clone, system install via make, custom prefix) and auto-downloads

#### Integration & UX
- `penv project bind <env> --direnv` — generate `.envrc` for [direnv](https://direnv.net/)-based auto-activation; auto-runs `direnv allow` when installed
- `penv activate` (no args) — interactive fzf picker when `fzf` is installed
- `penv remove` (no args) — interactive fzf multi-select picker when `fzf` is installed
- Plugin dispatch: unknown commands auto-fallback to `$PENV_PLUGIN_DIR/<cmd>.sh` for third-party extensibility

#### Shell Completion
- `scripts/penv-completion.fish` — fish shell tab completion, auto-completes all commands and environment names
- `penv-completion.bash` — improved timeout handling for environment listing

#### CI & Infrastructure
- `.github/workflows/ci.yml` — ShellCheck (`--severity=warning`) + `bash -n` syntax check on push and PR to `master`/`main`
- `.github/workflows/release.yml` — tag-triggered release CI: verifies tag matches `VERSION`, runs tests + shellcheck, builds Arch (`.pkg.tar.zst`) via Docker makepkg and Debian (`.deb`), publishes to GitHub Releases
- `.github/dependabot.yml` — automated weekly GitHub Actions dependency updates
- Makefile with targets: `all`, `pkg`, `deb`, `dist`, `install`, `clean`, `clean-pkg`, `clean-deb`, `test`, `test-shellcheck`, `help`
- `tools/make_tag.sh` — interactive tagging script that creates annotated git tags from `VERSION` file with PKGBUILD sync, uncommitted-change detection, and dry-run mode

#### Testing
- `tests/penv_create.bats`, `tests/penv_list.bats`, `tests/penv_remove.bats` — initial test suite (22 tests covering create/list/remove)
- `tests/penv_info.bats`, `tests/penv_config.bats`, `tests/penv_rename.bats` — 23 tests for new commands
- `tests/penv_doctor.bats`, `tests/penv_prune.bats`, `tests/penv_plugin.bats`, `tests/penv_project.bats`, `tests/penv_activate.bats` — 13 tests for doctor/prune/plugin/direnv/fzf
- `tests/penv_tree.bats`, `tests/penv_export.bats`, `tests/penv_import.bats`, `tests/penv_upgrade.bats` — 16 tests for tree/export/import/upgrade
- Total test count: 84 (up from 0 in 0.1.x)

#### Documentation
- `README.md` rewritten (411 lines) — architecture diagram, development guide, installation methods, command reference, contributing guide
- `CONTRIBUTING.md` — code of conduct, setup guide, coding standards (quoting, `[[` over `[`, timeouts, input validation), CI pipeline, PR process with Conventional Commits
- `LICENSE` — GPL v3 (matching PKGBUILD declaration)
- CI status badge in `README.md`
- `CHANGELOG.md` — [Unreleased] tracking section added for future development

#### Housekeeping
- `.gitignore` — build artifacts (`pkg/`, `*.tar.gz`, `*.deb`, `*.pkg.tar.zst`), IDE files (`.idea/`, `*.swp`), OS files (`.DS_Store`), runtime directories (`.omo/`)
- `VERSION` file — single source of truth for version number; consumed by `Makefile`, `penv` entry script, `tools/make_deb.sh`, and `tools/make_tag.sh`
- PKGBUILD — updated with comment referencing `VERSION` file; `pkgrel` bump for new packaging paths

### Changed

- **Version management**: `VERSION` file is now the single source of truth
  - `Makefile` reads `VERSION := $(shell cat VERSION)`
  - `penv` reads `VERSION` file at runtime with inline fallback
  - `tools/make_deb.sh` reads `VERSION` for package version
  - `tools/make_pkg.sh` and `PKGBUILD` reference `VERSION` via comments
- **Error handling**: Unified `die()` function replaces 28 ad-hoc `echo Error...` + `exit 1` patterns across all scripts; lives in `env.sh` for shared scripts, inlined in `penv` main entry and `tools/make_tag.sh`
- **sort-by-name in penv-list.sh**: Fixed array-losing bug — `IFS`-joined echo replaced with per-item `for` loop (`ENV_LIST[*]` was collapsing via `IFS`)
- **safety check in penv-remove.sh**: Path validation relaxed to allow `/tmp/`-based storage for bats CI testing
- **main dispatch in penv**: Extended from 10 to 32 recognized commands; `*)` fallback now checks plugin directory before erroring
- `select_version.sh` — simplified timeout variable reference
- `penv-completion.bash` — fixed timeout handling for environment listing

### Fixed

- All shellcheck warnings and errors resolved across 13 shell scripts (ShellCheck `--severity=warning` passes clean)
  - Variable quoting (`SC2086`) — all parameter expansions double-quoted
  - Array splitting (`SC2206`/`SC2207`) — `ls` → glob + `mapfile`
  - `local` + assignment split (`SC2155`) — declaration on separate line
  - Useless `echo $(ps)` → direct `ps` invocation (`SC2046`)
  - Useless `cat` → input redirection (`SC2002`)
  - Self-assign fallback (`SC2269`) — proper default-value pattern
  - Path safety (`SC2115`) — added `${var:?}` guard on rm -rf
  - Unused variable removal (`SC2034`)
  - Array quoting in for loop (`SC2068`)
  - Non-constant source (`SC1090`) — disable directive with comment
  - `cd` without error handling — added `|| die` where appropriate
- `penv-auto-activate.sh` — missing stderr redirect added to source fallback

## [0.1.2] - 2025-12-17

### Added
- Enhanced security with improved input validation across all scripts
- Added timeout mechanisms to prevent hanging operations in environment listing and Python version selection
- Added safety checks for directory operations in environment removal
- Improved error reporting with more descriptive messages
- Added signal trapping for graceful shutdowns in auto-clean script
- Implemented requirements management (export/import) functionality
- Implemented environment cloning feature
- Added project binding functionality to link environments with project directories
- Added disk usage reporting for virtual environments
- Created auto-activation helper for shell integration
- Added new commands: clone, requirements, project, usage
- Enhanced README with documentation for all new features

### Changed
- Fixed syntax errors in penv-list.sh and penv-show.sh scripts related to redirection
- Improved performance by replacing `ls` commands with safer globbing patterns in penv-list.sh
- Replaced external commands with bash parameter expansion for better performance
- Enhanced terminal compatibility for arrow key detection in Python version selection
- Standardized all shebangs to `#!/usr/bin/env bash` for better cross-platform compatibility
- Improved file iteration methods with safer array-based approaches
- Translated Chinese comments to English in select_version.sh for better maintainability
- Enhanced bash completion with additional options and timeout handling
- Improved validation and error handling across all scripts
- Used proper quoting for all variables to prevent injection issues
- Updated main script with new command handling and help information
- Updated packaging scripts with new version number 0.1.2

## [0.1.1] - 2025-09-01

### Added
- Added `--version` parameter to display version information
- Enhanced help information with detailed usage examples
- Optimized list output to display virtual environments sorted by name
- Added CHANGELOG.md file to record version change history
- Enhanced help system with command-specific help (`penv help <command>`)
- Added bash auto-completion support
- Improved list functionality with sorting and filtering options

### Changed
- Unified version numbers across all files to 0.1.1
- Fixed syntax errors in the main script
- Improved README.md with installation instructions, usage examples and troubleshooting guide
- Unified variable naming convention across all scripts (using UPPER_CASE_WITH_UNDERSCORES)
- Enhanced error handling in scripts with proper exit codes and error messages
- Optimized environment listing to use single traversal instead of double traversal
- Unified shell interpreter across all scripts to `#!/usr/bin/env bash` for better portability
- Enhanced input validation for virtual environment names and command arguments
- Added input validation to prevent special characters in environment names
- Enhanced PKGBUILD with proper handling of new files and improved package metadata
- Enhanced list display with color coding, activation status and improved formatting
- Fixed virtual environment activation path error issue

## [0.1.0] - 2024-XX-XX

### Added
- Implemented basic functions: create, list, remove, activate, show, deactivate, and clean virtual environments
- Supported packaging for ArchLinux/Manjaro and Debian/Ubuntu systems
- Provided command-line interface for managing Python virtual environments