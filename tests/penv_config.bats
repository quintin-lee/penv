#!/usr/bin/env bats

setup() {
    export HOME="${BATS_TEST_TMPDIR}/home"
    export VENV_STORAGE_DIR="${BATS_TEST_TMPDIR}/venv_storage"
    mkdir -p "$VENV_STORAGE_DIR"
    mkdir -p "${HOME}/.config/penv"
}

teardown() {
    rm -rf "${BATS_TEST_TMPDIR}"
}

@test "penv config: list shows message when empty" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-config.sh" list
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "No configuration set"
}

@test "penv config: set default_python" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-config.sh" set default_python python3.11
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "default_python=python3.11"
    # Verify the config file exists
    grep -q "default_python=python3.11" "${HOME}/.config/penv/config"
}

@test "penv config: get returns value after set" {
    echo "default_python=python3.10" > "${HOME}/.config/penv/config"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-config.sh" get default_python
    [ "$status" -eq 0 ]
    [ "$output" = "python3.10" ]
}

@test "penv config: get fails for unknown key" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-config.sh" get nonexistent
    [ "$status" -ne 0 ]
}

@test "penv config: set fails for unknown key" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-config.sh" set foo bar
    [ "$status" -ne 0 ]
}

@test "penv config: set storage_dir requires absolute path" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-config.sh" set storage_dir relative/path
    [ "$status" -ne 0 ]
}

@test "penv config: set storage_dir accepts absolute path" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-config.sh" set storage_dir /opt/venvs
    [ "$status" -eq 0 ]
    grep -q "storage_dir=/opt/venvs" "${HOME}/.config/penv/config"
}

@test "penv config: set updates existing value" {
    echo "default_python=python3.10" > "${HOME}/.config/penv/config"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-config.sh" set default_python python3.12
    [ "$status" -eq 0 ]
    # Should have replaced, not appended
    run grep -c "default_python=" "${HOME}/.config/penv/config"
    [ "$output" -eq 1 ]
    grep -q "default_python=python3.12" "${HOME}/.config/penv/config"
}

@test "penv config: set cannot set empty value" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-config.sh" set default_python ""
    [ "$status" -ne 0 ]
}
