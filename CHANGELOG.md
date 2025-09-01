# Changelog

All notable changes to penv will be documented in this file.

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

## [0.1.0] - 2024-XX-XX

### Added
- Implemented basic functions: create, list, remove, activate, show, deactivate, and clean virtual environments
- Supported packaging for ArchLinux/Manjaro and Debian/Ubuntu systems
- Provided command-line interface for managing Python virtual environments