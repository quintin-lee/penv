#!/usr/bin/env bats

setup() {
    export VENV_STORAGE_DIR="${BATS_TEST_TMPDIR}/venv_storage"
    mkdir -p "$VENV_STORAGE_DIR"
    # Create a minimal fake env
    mkdir -p "${VENV_STORAGE_DIR}/testenv/bin"
    touch "${VENV_STORAGE_DIR}/testenv/bin/python"
    printf "A test environment\n" > "${VENV_STORAGE_DIR}/testenv/description.txt"
}

teardown() {
    rm -rf "${VENV_STORAGE_DIR}"
}

@test "penv info: fails without env name" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-info.sh"
    [ "$status" -ne 0 ]
}

@test "penv info: fails for non-existent env" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-info.sh" nonexistent
    [ "$status" -ne 0 ]
}

@test "penv info: shows details for existing env" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-info.sh" testenv
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "Name:           testenv"
    echo "$output" | grep -q "Description:    A test environment"
    echo "$output" | grep -q "Path:           ${VENV_STORAGE_DIR}/testenv"
    echo "$output" | grep -q "Activated:      no"
}

@test "penv info: shows activated status" {
    echo "1" > "${VENV_STORAGE_DIR}/testenv.activate"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-info.sh" testenv
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "Activated:      yes"
}

@test "penv info: omits description line when no description" {
    mkdir -p "${VENV_STORAGE_DIR}/plainenv/bin"
    touch "${VENV_STORAGE_DIR}/plainenv/bin/python"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-info.sh" plainenv
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "Name:           plainenv"
    # Should not output a Description: line
    ! echo "$output" | grep -q "Description:"
}

@test "penv info: rejects invalid name" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-info.sh" "bad/name"
    [ "$status" -ne 0 ]
}
