# Changelog

All notable changes to penv will be documented in this file.

## [Unreleased]

### Added

- `penv info <env>` — show detailed information about a virtual environment
- `penv config [list|get|set]` — manage penv configuration (default_python, storage_dir)
- `penv rename <old> <new>` — rename a virtual environment (updates activation markers and project bindings)
- `scripts/penv-completion.fish` — fish shell tab completion (auto-completes all commands and environment names)
- `tests/penv_info.bats`, `tests/penv_config.bats`, `tests/penv_rename.bats` — 23 new test cases
- `tools/make_tag.sh` — script to create annotated git tags from `VERSION` file
- Makefile with targets: `all`, `pkg`, `deb`, `dist`, `install`, `clean`, `help`
- `.github/workflows/ci.yml` — ShellCheck + bash syntax check on push and PR
- `.github/dependabot.yml` — automated weekly dependency updates
- `.gitignore` with build artifacts, IDE, and OS entries
- `LICENSE` — GPL v3
- CI status badge in README

### Changed

- Unified version management: `VERSION` file is now the single source of truth
  - `Makefile`, `penv` entry script, and `tools/make_deb.sh` read from `VERSION`
  - PKGBUILD updated with comment referencing `VERSION` file
- `README.md` rewritten with architecture guide, development docs, contributing guide
- `penv-completion.bash` fixed timeout handling for environment listing
- `select_version.sh` simplified timeout variable reference

### Fixed

- All shellcheck warnings and errors resolved across 13 shell scripts
  - Variable quoting (`SC2086`), array splitting (`SC2206`/`SC2207`)
  - Useless `echo $(ps)` → direct `ps` invocation (`SC2046`)
  - Useless `cat` → input redirection (`SC2002`)
  - Self-assign fallback (`SC2269`)
  - Unused variable removal (`SC2034`)

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