# Contributing to penv

Thanks for your interest in contributing! 🎉

penv is a community-driven CLI tool for managing Python virtual environments. Whether you're fixing a bug, adding a feature, or improving documentation — every contribution is welcome.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
  - [Report a Bug](#report-a-bug)
  - [Suggest a Feature](#suggest-a-feature)
  - [Submit Code Changes](#submit-code-changes)
  - [Improve Documentation](#improve-documentation)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [CI Pipeline](#ci-pipeline)
- [Pull Request Process](#pull-request-process)
- [Release Process](#release-process)

---

## Code of Conduct

Be respectful, constructive, and inclusive. We're all here to make penv better.

---

## How to Contribute

### Report a Bug

Open a [GitHub Issue](https://github.com/quintin-lee/penv/issues/new) and include:

- **Steps to reproduce** — minimal commands that trigger the issue
- **Expected vs actual behavior**
- **System info** — `penv --version`, OS, shell, Python version
- **Relevant output** — especially error messages or unexpected behavior

### Suggest a Feature

Open a [GitHub Issue](https://github.com/quintin-lee/penv/issues/new) and describe:

- The use case — what problem are you solving?
- A proposed interface — what would the command look like?
- Any alternatives you've considered

### Submit Code Changes

1. **Fork** the repository
2. **Create a feature branch** (`git checkout -b feature/my-change`)
3. **Make your changes** following the standards below
4. **Validate locally** with the CI checks (see [CI Pipeline](#ci-pipeline))
5. **Submit a Pull Request** targeting `master`

### Improve Documentation

Documentation improvements are always appreciated — typos, clarifications, examples, or translation fixes. Open a PR with the changes directly.

---

## Development Setup

### Prerequisites

- Bash 4.0+
- Python 3 with `venv` module
- `expect` (for `penv activate`)
- `coreutils` (for `realpath`, `timeout`)

### Quick Start

```shell
git clone https://github.com/quintin-lee/penv.git
cd penv
export PATH="$PWD:$PATH"
penv --version
```

No build step required — penv is pure shell scripts.

### Directory Structure

```
├── penv                  # Entry point — command dispatcher
├── scripts/              # Subcommand implementations
├── tools/                # Packaging and release scripts
├── Makefile              # Build orchestration
├── VERSION               # Single source of truth for version
└── .github/workflows/    # CI configuration
```

---

## Coding Standards

All scripts use `#!/usr/bin/env bash`.

### Naming

| Scope | Convention | Example |
|---|---|---|
| Global variables | `UPPER_CASE_WITH_UNDERSCORES` | `VENV_STORAGE_DIR` |
| Functions | `lower_case_with_underscores` | `penv_list_environments` |
| Script files | `penv-<command>.sh` | `penv-create.sh` |

### Rules

- **Quote all variable expansions** — `"$var"` not `$var`
- **Validate input** at every entry point (environment names, paths, flags)
- **Use `[[ ... ]]`** instead of `[ ... ]` for conditional expressions
- **Check return values** — don't assume commands succeed
- **Use `timeout`** for any operation that could hang (network calls, subprocesses)
- **Avoid external commands** where bash builtins suffice (e.g. parameter expansion over `sed`/`awk`)
- **Exit with meaningful codes** — `0` for success, non-zero for errors

### ShellCheck

All shell scripts must pass `shellcheck` with `--severity=warning`:

```shell
shellcheck -x --severity=warning scripts/*.sh tools/*.sh penv
```

Run this before submitting a PR. The CI will reject any warnings or errors.

---

## CI Pipeline

The project uses **GitHub Actions** for continuous integration.

### What CI Checks

| Check | Command | Runs On |
|---|---|---|
| ShellCheck | `shellcheck -x --severity=warning scripts/*.sh tools/*.sh penv` | push/PR to `master`/`main` |
| Syntax Check | `bash -n scripts/*.sh tools/*.sh penv` | push/PR to `master`/`main` |
| Dependabot | Automatic weekly dependency updates | weekly |

### Running CI Locally

```shell
# Install ShellCheck
# Ubuntu/Debian: sudo apt install shellcheck
# ArchLinux:      sudo pacman -S shellcheck
# macOS:          brew install shellcheck

# Run checks
shellcheck -x --severity=warning scripts/*.sh tools/*.sh penv
bash -n scripts/*.sh tools/*.sh penv
```

Your PR must pass all CI checks before it will be merged.

---

## Pull Request Process

1. **Validate locally** — run ShellCheck and syntax checks first
2. **Keep changes focused** — one PR per logical change (bug fix, feature, refactor)
3. **Write a descriptive title** following [Conventional Commits](https://www.conventionalcommits.org/) style:
   - `feat: add penv rename command`
   - `fix: handle spaces in environment name`
   - `docs: update installation instructions`
   - `refactor: unify activation tracking`
4. **Link the issue** — if addressing an existing issue, reference it in the description
5. **Wait for CI** — the pipeline must pass before review

---

## Release Process

Maintainers follow these steps for releases:

1. Update `VERSION` file with the new version number
2. Move [Unreleased] changelog entries to a new version header
3. Create an annotated tag using `tools/make_tag.sh`
4. Push the tag — CI will build and attach release packages automatically

---

## Questions?

Open a [Discussion](https://github.com/quintin-lee/penv/discussions) or an Issue for any questions about contributing.
