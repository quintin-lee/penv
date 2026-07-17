#!/usr/bin/env bats

setup() {
    export HOME="${BATS_TEST_TMPDIR}/home"
    export VENV_STORAGE_DIR="${BATS_TEST_TMPDIR}/venv_storage"
    mkdir -p "$VENV_STORAGE_DIR"
    # Create a real venv using python3
    if command -v python3 &>/dev/null; then
        python3 -m venv "${VENV_STORAGE_DIR}/testenv" 2>/dev/null || true
    fi
}

teardown() {
    rm -rf "${BATS_TEST_TMPDIR}"
}

@test "penv tree: fails without env name" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-tree.sh"
    [ "$status" -ne 0 ]
}

@test "penv tree: fails for non-existent env" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-tree.sh" nonexistent
    [ "$status" -ne 0 ]
}

@test "penv tree: shows header for existing env" {
    if [[ ! -d "${VENV_STORAGE_DIR}/testenv/bin" ]]; then
        skip "python3 not available to create test env"
    fi
    run "${BATS_TEST_DIRNAME}/../scripts/penv-tree.sh" testenv
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "testenv"
}

@test "penv tree: rejects invalid name" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-tree.sh" "../evil"
    [ "$status" -ne 0 ]
}
