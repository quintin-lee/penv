#!/usr/bin/env bats

load setup

PENV_REMOVE="${BATS_TEST_DIRNAME}/../scripts/penv-remove.sh"

@test "remove: fails with no name" {
    run "$PENV_REMOVE"
    [ "$status" -eq 1 ]
}

@test "remove: fails with invalid name" {
    run "$PENV_REMOVE" 'invalid$name'
    [ "$status" -eq 1 ]
}

@test "remove: removes existing environment" {
    fake_env testenv
    run "$PENV_REMOVE" testenv
    [ "$status" -eq 0 ]
    [ ! -d "${VENV_STORAGE_DIR}/testenv" ]
    [[ "$output" == *"successfully deleted"* ]]
}

@test "remove: fails on non-existent environment" {
    run "$PENV_REMOVE" nonexistent
    [ "$status" -eq 1 ]
    [[ "$output" == *"does not exist"* ]]
}

@test "remove: removes environment and leaves others intact" {
    fake_env keepme
    fake_env deleteme
    run "$PENV_REMOVE" deleteme
    [ "$status" -eq 0 ]
    [ ! -d "${VENV_STORAGE_DIR}/deleteme" ]
    [ -d "${VENV_STORAGE_DIR}/keepme" ]
}
