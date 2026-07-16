#!/usr/bin/env bats

setup() {
    export HOME="${BATS_TEST_TMPDIR}/home"
    export VENV_STORAGE_DIR="${BATS_TEST_TMPDIR}/venv_storage"
    mkdir -p "$VENV_STORAGE_DIR"
    mkdir -p "${HOME}/.config/penv"
    # Create a test environment
    mkdir -p "${VENV_STORAGE_DIR}/myenv/bin"
    touch "${VENV_STORAGE_DIR}/myenv/bin/python"
    touch "${VENV_STORAGE_DIR}/myenv/bin/activate"
    touch "${VENV_STORAGE_DIR}/myenv/pyvenv.cfg"
    # Change to a project directory
    export PROJECT_DIR="${BATS_TEST_TMPDIR}/project"
    mkdir -p "$PROJECT_DIR"
}

teardown() {
    rm -rf "${BATS_TEST_TMPDIR}"
}

@test "penv project bind: creates .penv file" {
    cd "$PROJECT_DIR"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-project.sh" bind myenv
    [ "$status" -eq 0 ]
    [ -f "${PROJECT_DIR}/.penv" ]
    [[ "$(cat "${PROJECT_DIR}/.penv")" == "myenv" ]]
}

@test "penv project bind: fails for non-existent env" {
    cd "$PROJECT_DIR"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-project.sh" bind nonexistent
    [ "$status" -eq 1 ]
    [ ! -f "${PROJECT_DIR}/.penv" ]
}

@test "penv project bind: --direnv creates .envrc" {
    cd "$PROJECT_DIR"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-project.sh" bind myenv --direnv
    [ "$status" -eq 0 ]
    [ -f "${PROJECT_DIR}/.envrc" ]
    # Should contain the path to the activate script
    grep -q "myenv/bin/activate" "${PROJECT_DIR}/.envrc"
    # Should NOT create a .penv file
    [ ! -f "${PROJECT_DIR}/.penv" ]
}

@test "penv project bind: --direnv creates correct source path" {
    cd "$PROJECT_DIR"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-project.sh" bind myenv --direnv
    [ "$status" -eq 0 ]
    cat "${PROJECT_DIR}/.envrc" | grep -q "^source \"${VENV_STORAGE_DIR}/myenv/bin/activate\""
}

@test "penv project unbind: removes .penv" {
    cd "$PROJECT_DIR"
    echo "myenv" > .penv
    run "${BATS_TEST_DIRNAME}/../scripts/penv-project.sh" unbind
    [ "$status" -eq 0 ]
    [ ! -f "${PROJECT_DIR}/.penv" ]
}

@test "penv project show: shows binding" {
    cd "$PROJECT_DIR"
    echo "myenv" > .penv
    run "${BATS_TEST_DIRNAME}/../scripts/penv-project.sh" show
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "myenv"
}

@test "penv project show: warns when no binding" {
    cd "$PROJECT_DIR"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-project.sh" show
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "not bound"
}
