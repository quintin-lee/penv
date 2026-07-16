#!/usr/bin/env bats

setup() {
    export HOME="${BATS_TEST_TMPDIR}/home"
    export VENV_STORAGE_DIR="${BATS_TEST_TMPDIR}/venv_storage"
    mkdir -p "$VENV_STORAGE_DIR"
    # Healthy env (used by all tests)
    mkdir -p "${VENV_STORAGE_DIR}/good/bin"
    touch "${VENV_STORAGE_DIR}/good/bin/python"
    touch "${VENV_STORAGE_DIR}/good/bin/activate"
    touch "${VENV_STORAGE_DIR}/good/pyvenv.cfg"
}

create_broken() {
    mkdir -p "${VENV_STORAGE_DIR}/broken/bin"
}

teardown() {
    rm -rf "${BATS_TEST_TMPDIR}"
}

@test "penv prune: reports none when all healthy" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-prune.sh" --force
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "No broken environments"
}

@test "penv prune: detects broken envs" {
    create_broken
    run "${BATS_TEST_DIRNAME}/../scripts/penv-prune.sh" --force
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "broken"
}

@test "penv prune: removes broken env with --force" {
    create_broken
    run "${BATS_TEST_DIRNAME}/../scripts/penv-prune.sh" --force
    [ "$status" -eq 0 ]
    [ ! -d "${VENV_STORAGE_DIR}/broken" ]
}

@test "penv prune: keeps healthy envs when removing broken" {
    create_broken
    run "${BATS_TEST_DIRNAME}/../scripts/penv-prune.sh" --force
    [ "$status" -eq 0 ]
    [ -d "${VENV_STORAGE_DIR}/good" ]
    [ ! -d "${VENV_STORAGE_DIR}/broken" ]
}

@test "penv prune: cleans up activation markers" {
    create_broken
    echo "1" > "${VENV_STORAGE_DIR}/broken.activate"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-prune.sh" --force
    [ ! -f "${VENV_STORAGE_DIR}/broken.activate" ]
    [ ! -d "${VENV_STORAGE_DIR}/broken" ]
}
