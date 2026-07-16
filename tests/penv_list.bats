#!/usr/bin/env bats

load setup

PENV_LIST="${BATS_TEST_DIRNAME}/../scripts/penv-list.sh"

@test "list: shows empty message when no environments" {
    run "$PENV_LIST"
    [ "$status" -eq 0 ]
    [[ "$output" == *"No virtual environments found."* ]]
}

@test "list: lists single environment" {
    fake_env myenv
    run "$PENV_LIST"
    [ "$status" -eq 0 ]
    [[ "$output" == *"myenv"* ]]
}

@test "list: lists multiple environments" {
    fake_env alpha
    fake_env beta
    fake_env gamma
    run "$PENV_LIST"
    [ "$status" -eq 0 ]
    [[ "$output" == *"alpha"* ]]
    [[ "$output" == *"beta"* ]]
    [[ "$output" == *"gamma"* ]]
}

@test "list: shows total count" {
    fake_env one
    fake_env two
    run "$PENV_LIST"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Total:"*"2"* ]]
}

@test "list: filters by pattern" {
    fake_env project-alpha
    fake_env project-beta
    fake_env personal
    run "$PENV_LIST" --filter=project-
    [ "$status" -eq 0 ]
    [[ "$output" == *"project-alpha"* ]]
    [[ "$output" == *"project-beta"* ]]
    [[ ! "$output" == *"personal"* ]]
}

@test "list: filter shows dedicated message on no match" {
    fake_env abc
    run "$PENV_LIST" --filter=nonexistent
    [ "$status" -eq 0 ]
    [[ "$output" == *"No virtual environments found"*"nonexistent"* ]]
}

@test "list: sort by name (default) is alphabetical" {
    fake_env zed
    fake_env alpha
    fake_env beta
    run "$PENV_LIST" --sort-by=name
    [ "$status" -eq 0 ]
    # alpha should appear before zed
    [[ "${output}" == *"alpha"*"zed"* ]]
}

@test "list: sort by date does not crash" {
    fake_env older
    fake_env newer
    # Set explicit timestamps: older @ 2024-01-01, newer @ 2025-01-01
    touch -t 202401010000 "${VENV_STORAGE_DIR}/older"
    touch -t 202501010000 "${VENV_STORAGE_DIR}/newer"
    run "$PENV_LIST" --sort-by=date
    [ "$status" -eq 0 ]
    [[ "$output" == *"older"*"newer"* ]]
}

@test "list: unknown option fails" {
    run "$PENV_LIST" --bogus
    [ "$status" -eq 1 ]
}
