#!/usr/bin/env bats

setup() {
    export HOME="${BATS_TEST_TMPDIR}/home"
    export VENV_STORAGE_DIR="${BATS_TEST_TMPDIR}/venv_storage"
    mkdir -p "$VENV_STORAGE_DIR"
    # Create a real venv and export it
    if command -v python3 &>/dev/null; then
        python3 -m venv "${VENV_STORAGE_DIR}/sourceenv" 2>/dev/null || true
        if [[ -d "${VENV_STORAGE_DIR}/sourceenv/bin" ]]; then
            cd "${BATS_TEST_TMPDIR}"
            "${BATS_TEST_DIRNAME}/../scripts/penv-export.sh" sourceenv &>/dev/null || true
        fi
    fi
}

teardown() {
    rm -rf "${BATS_TEST_TMPDIR}"
}

@test "penv import: fails without archive arg" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-import.sh"
    [ "$status" -ne 0 ]
}

@test "penv import: fails for non-existent archive" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-import.sh" /tmp/nonexistent.tar.gz
    [ "$status" -ne 0 ]
}

@test "penv import: imports environment with original name" {
    if [[ ! -f "${BATS_TEST_TMPDIR}/sourceenv.tar.gz" ]]; then
        skip "python3 not available to create source env"
    fi
    # Remove the setup-created env so import can create it
    rm -rf "${VENV_STORAGE_DIR}/sourceenv"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-import.sh" "${BATS_TEST_TMPDIR}/sourceenv.tar.gz"
    [ "$status" -eq 0 ]
    [ -d "${VENV_STORAGE_DIR}/sourceenv" ]
    [ -f "${VENV_STORAGE_DIR}/sourceenv/bin/python" ]
    [ -f "${VENV_STORAGE_DIR}/sourceenv/pyvenv.cfg" ]
    [ -f "${VENV_STORAGE_DIR}/sourceenv/bin/activate" ]
}

@test "penv import: imports with custom name" {
    if [[ ! -f "${BATS_TEST_TMPDIR}/sourceenv.tar.gz" ]]; then
        skip "python3 not available to create source env"
    fi
    run "${BATS_TEST_DIRNAME}/../scripts/penv-import.sh" "${BATS_TEST_TMPDIR}/sourceenv.tar.gz" "customname"
    [ "$status" -eq 0 ]
    [ -d "${VENV_STORAGE_DIR}/customname" ]
}

@test "penv import: fails if name already exists" {
    if [[ ! -f "${BATS_TEST_TMPDIR}/sourceenv.tar.gz" ]]; then
        skip "python3 not available to create source env"
    fi
    mkdir -p "${VENV_STORAGE_DIR}/sourceenv"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-import.sh" "${BATS_TEST_TMPDIR}/sourceenv.tar.gz"
    [ "$status" -ne 0 ]
}
