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

@test "penv doctor: runs and reports storage ok" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-doctor.sh"
    # Doctor may exit non-zero if optional deps (expect) are missing — that's OK
    echo "$output" | grep -q "VENV_STORAGE_DIR exists"
}

@test "penv doctor: creates storage dir on first run" {
    rm -rf "$VENV_STORAGE_DIR"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-doctor.sh"
    # env.sh creates the directory automatically, so doctor should see it
    echo "$output" | grep -q "VENV_STORAGE_DIR exists"
    [ -d "$VENV_STORAGE_DIR" ]
}

@test "penv doctor: reports stale activation markers" {
    echo "1" > "${VENV_STORAGE_DIR}/ghostenv.activate"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-doctor.sh"
    echo "$output" | grep -q "Stale"
}

@test "penv doctor: detects broken envs" {
    mkdir -p "${VENV_STORAGE_DIR}/broken/bin"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-doctor.sh"
    echo "$output" | grep -q "broken"
}

@test "penv doctor: reports healthy envs" {
    mkdir -p "${VENV_STORAGE_DIR}/good/bin"
    touch "${VENV_STORAGE_DIR}/good/bin/python"
    touch "${VENV_STORAGE_DIR}/good/bin/activate"
    touch "${VENV_STORAGE_DIR}/good/pyvenv.cfg"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-doctor.sh"
    echo "$output" | grep -q "All environments appear healthy"
}
