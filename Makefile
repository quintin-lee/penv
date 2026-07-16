# penv - Python venv Management Tool
# Makefile for packaging and installation
#
# Targets:
#   make all      — Build both ArchLinux and Debian packages (default)
#   make pkg      — Build ArchLinux package (.pkg.tar.zst)
#   make deb      — Build Debian package (.deb)
#   make dist     — Create distribution tarball (penv.tar.gz)
#   make install  — Install penv to system (use DESTDIR for staging)
#   make clean    — Remove all build artifacts
#   make help     — Show this help
#
# Variables:
#   VERSION=0.1.2    Override package version
#   DESTDIR=         Staging root for install (e.g. DESTDIR=/tmp/penv-stage)

VERSION := $(shell cat VERSION 2>/dev/null)
# Allow command-line override: make VERSION=x.y.z
VERSION ?= 0.1.2
DESTDIR ?=

.PHONY: all pkg deb dist install clean clean-pkg clean-deb help

# ── Default target ──────────────────────────────────────────────────

all: pkg deb

# ── ArchLinux package ───────────────────────────────────────────────

pkg: penv.tar.gz
	@echo "==> Building ArchLinux package (version $(VERSION))..."
	@bash tools/make_pkg.sh

# ── Debian package ──────────────────────────────────────────────────

deb: clean-deb
	@echo "==> Building Debian package (version $(VERSION))..."
	@bash tools/make_deb.sh

# ── Distribution tarball ────────────────────────────────────────────

penv.tar.gz: penv scripts/*.sh scripts/*.exp scripts/penv-completion.bash scripts/penv.service
	@echo "==> Creating distribution tarball..."
	@tar zcf $@ penv scripts

dist: penv.tar.gz
	@echo "Distribution tarball created: penv.tar.gz"

# ── Direct installation ─────────────────────────────────────────────

install:
	@echo "==> Installing penv..."
	@install -d "$(DESTDIR)/usr/local/bin"
	@install -d "$(DESTDIR)/usr/local/penv/scripts"
	@install -m 755 penv "$(DESTDIR)/usr/local/penv/"
	@ln -sf "/usr/local/penv/penv" "$(DESTDIR)/usr/local/bin/penv"
	@for f in scripts/*.sh scripts/*.exp; do \
		install -m 755 "$$f" "$(DESTDIR)/usr/local/penv/scripts/"; \
	done
	@install -m 644 scripts/penv-completion.bash "$(DESTDIR)/usr/local/penv/scripts/"
	@echo "Installation complete."
	@echo "  penv -> /usr/local/penv/penv"
	@echo "  symlink -> /usr/local/bin/penv"

# ── Cleanup ─────────────────────────────────────────────────────────

clean: clean-pkg clean-deb
	@rm -f penv.tar.gz
	@echo "==> All build artifacts removed."

clean-pkg:
	@rm -f penv-*.pkg.tar.zst
	@rm -rf src/penv/
	@echo "==> ArchLinux build artifacts removed."

clean-deb:
	@rm -rf dist/
	@rm -f penv_*.deb
	@echo "==> Debian build artifacts removed."

# ── Testing ────────────────────────────────────────────────────────────

.PHONY: test test-shellcheck

test:
	@echo "==> Running bats test suite..."
	@npx bats tests/

test-shellcheck:
	@echo "==> Checking shell script syntax..."
	@shellcheck -x --severity=warning scripts/*.sh tools/*.sh penv tests/setup.bash
	@bash -n scripts/*.sh tools/*.sh penv
	@echo "==> All shell scripts pass."

# ── Help ────────────────────────────────────────────────────────────

help:
	@echo "penv - Python venv Management Tool"
	@echo ""
	@echo "Usage:  make <target> [VERSION=x.y.z] [DESTDIR=/path]"
	@echo ""
	@echo "Targets:"
	@echo "  all       Build both ArchLinux and Debian packages (default)"
	@echo "  pkg       Build ArchLinux package  ->  penv-\$${VERSION}-\$${pkgrel}-any.pkg.tar.zst"
	@echo "  deb       Build Debian package     ->  penv_\$${VERSION}-all.deb"
	@echo "  dist      Create distribution tarball ->  penv.tar.gz"
	@echo "  install   Install penv to system"
	@echo "  clean     Remove all build artifacts"
	@echo "  clean-pkg Remove ArchLinux artifacts only"
	@echo "  clean-deb Remove Debian artifacts only"
	@echo "  help      Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  VERSION   Package version (default: $(VERSION))"
	@echo "  DESTDIR   Staging root for install (default: /)"
	@echo ""
	@echo "Examples:"
	@echo "  make               # Build both packages"
	@echo "  make pkg           # Build ArchLinux package only"
	@echo "  make deb           # Build Debian package only"
	@echo "  make VERSION=0.2.0 pkg   # Build with custom version"
	@echo "  make DESTDIR=/tmp/stage install   # Stage install to directory"
	@echo "  make clean         # Clean everything"
