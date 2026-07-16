#!/usr/bin/env bats

setup() {
    export HOME="${BATS_TEST_TMPDIR}/home"
    export VENV_STORAGE_DIR="${BATS_TEST_TMPDIR}/venv_storage"
    mkdir -p "$VENV_STORAGE_DIR"
    mkdir -p "${VENV_STORAGE_DIR}/myenv/bin"
    touch "${VENV_STORAGE_DIR}/myenv/bin/python"
    touch "${VENV_STORAGE_DIR}/myenv/bin/activate"
    touch "${VENV_STORAGE_DIR}/myenv/pyvenv.cfg"
}

teardown() {
    rm -rf "${BATS_TEST_TMPDIR}"
}

@test "penv activate: shows message when no name given" {
    if command -v fzf &>/dev/null; then
        skip "fzf is installed — cannot test non-fzf error path"
    fi
    run "${BATS_TEST_DIRNAME}/../scripts/penv-activate.sh"
    [ "$status" -eq 1 ]
    echo "$output" | grep -qi "specify"
}

@test "penv activate: fails for non-existent env" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-activate.sh" nonexistent
    [ "$status" -eq 1 ]
}

@test "penv activate: rejects invalid name" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-activate.sh" "bad/name"
    [ "$status" -eq 1 ]
    echo "$output" | grep -qi "invalid"
}
