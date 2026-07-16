#!/usr/bin/env bats

load setup

PENV_CREATE="${BATS_TEST_DIRNAME}/../scripts/penv-create.sh"

@test "create: fails with no name" {
    run "$PENV_CREATE"
    [ "$status" -eq 1 ]
}

@test "create: fails with invalid name (special chars)" {
    run "$PENV_CREATE" 'invalid$name'
    [ "$status" -eq 1 ]
}

@test "create: fails with invalid name (spaces)" {
    run "$PENV_CREATE" 'my env'
    [ "$status" -eq 1 ]
}

@test "create: fails with invalid name (slashes)" {
    run "$PENV_CREATE" 'a/b/c'
    [ "$status" -eq 1 ]
}

@test "create: succeeds with valid name" {
    check_python3
    run "$PENV_CREATE" testenv
    [ "$status" -eq 0 ]
    [ -d "${VENV_STORAGE_DIR}/testenv" ]
    [[ "$output" == *"created successfully"* ]]
}

@test "create: succeeds with valid name containing dots and hyphens" {
    check_python3
    run "$PENV_CREATE" 'my-env.v2'
    [ "$status" -eq 0 ]
    [ -d "${VENV_STORAGE_DIR}/my-env.v2" ]
}

@test "create: fails on duplicate name" {
    check_python3
    "$PENV_CREATE" dupenv
    run "$PENV_CREATE" dupenv
    [ "$status" -eq 1 ]
    [[ "$output" == *"already exists"* ]]
}

@test "create: stores description file when provided" {
    check_python3
    run "$PENV_CREATE" descenv "My test environment"
    [ "$status" -eq 0 ]
    [ -f "${VENV_STORAGE_DIR}/descenv/description.txt" ]
}
