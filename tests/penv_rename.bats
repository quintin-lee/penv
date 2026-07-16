#!/usr/bin/env bats

setup() {
    export HOME="${BATS_TEST_TMPDIR}/home"
    export VENV_STORAGE_DIR="${BATS_TEST_TMPDIR}/venv_storage"
    mkdir -p "$VENV_STORAGE_DIR"
    mkdir -p "${HOME}"
    # Create a minimal fake env
    mkdir -p "${VENV_STORAGE_DIR}/oldname/bin"
    touch "${VENV_STORAGE_DIR}/oldname/bin/python"
}

teardown() {
    rm -rf "${BATS_TEST_TMPDIR}"
}

@test "penv rename: fails without args" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-rename.sh"
    [ "$status" -ne 0 ]
}

@test "penv rename: fails with only one arg" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-rename.sh" oldname
    [ "$status" -ne 0 ]
}

@test "penv rename: fails for non-existent env" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-rename.sh" nonexistent newname
    [ "$status" -ne 0 ]
}

@test "penv rename: fails if new name already exists" {
    mkdir -p "${VENV_STORAGE_DIR}/existing/bin"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-rename.sh" oldname existing
    [ "$status" -ne 0 ]
}

@test "penv rename: renames successfully" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-rename.sh" oldname newname
    [ "$status" -eq 0 ]
    [ ! -d "${VENV_STORAGE_DIR}/oldname" ]
    [ -d "${VENV_STORAGE_DIR}/newname" ]
    [ -f "${VENV_STORAGE_DIR}/newname/bin/python" ]
}

@test "penv rename: renames activation marker" {
    echo "2" > "${VENV_STORAGE_DIR}/oldname.activate"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-rename.sh" oldname newname2
    [ "$status" -eq 0 ]
    [ ! -f "${VENV_STORAGE_DIR}/oldname.activate" ]
    [ -f "${VENV_STORAGE_DIR}/newname2.activate" ]
}

@test "penv rename: updates project bindings" {
    mkdir -p "${HOME}/myproject"
    echo "oldname" > "${HOME}/myproject/.penv"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-rename.sh" oldname newproj
    [ "$status" -eq 0 ]
    run cat "${HOME}/myproject/.penv"
    [ "$output" = "newproj" ]
}

@test "penv rename: rejects invalid name" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-rename.sh" oldname "bad/name"
    [ "$status" -ne 0 ]
}
