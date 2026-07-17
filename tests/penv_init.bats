#!/usr/bin/env bats

setup() {
    export HOME="${BATS_TEST_TMPDIR}/home"
    export VENV_STORAGE_DIR="${BATS_TEST_TMPDIR}/venv_storage"
    export SHELL="/bin/bash"
    mkdir -p "$VENV_STORAGE_DIR"
    mkdir -p "${HOME}/.config/penv"
    mkdir -p "${HOME}/.config/penv/plugins"
    # Simulate a shell profile
    echo "" > "${HOME}/.bashrc"
}

teardown() {
    rm -rf "${BATS_TEST_TMPDIR}"
}

@test "penv init --yes: creates plugin directory" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-init.sh" --yes
    [ "$status" -eq 0 ]
    [ -d "${HOME}/.config/penv/plugins" ]
}

@test "penv init --yes: creates config file" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-init.sh" --yes
    [ "$status" -eq 0 ]
    [ -f "${HOME}/.config/penv/config" ]
}

@test "penv init --yes: creates config with default_python" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-init.sh" --yes
    [ "$status" -eq 0 ]
    grep -q "default_python" "${HOME}/.config/penv/config"
}

@test "penv init --yes: adds profile hook to .bashrc" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-init.sh" --yes
    [ "$status" -eq 0 ]
    grep -q "penv-auto-activate" "${HOME}/.bashrc"
}

@test "penv init --yes: is idempotent" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-init.sh" --yes
    [ "$status" -eq 0 ]
    run "${BATS_TEST_DIRNAME}/../scripts/penv-init.sh" --yes
    [ "$status" -eq 0 ]
    # Should not duplicate profile entries
    count=$(grep -c "penv-auto-activate" "${HOME}/.bashrc" || true)
    [ "$count" -eq 1 ]
}
