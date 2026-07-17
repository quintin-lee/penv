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

@test "penv export: fails without env name" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-export.sh"
    [ "$status" -ne 0 ]
}

@test "penv export: fails for non-existent env" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-export.sh" nonexistent
    [ "$status" -ne 0 ]
}

@test "penv export: creates a valid tarball" {
    if [[ ! -d "${VENV_STORAGE_DIR}/testenv/bin" ]]; then
        skip "python3 not available to create test env"
    fi
    cd "${BATS_TEST_TMPDIR}"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-export.sh" testenv
    [ "$status" -eq 0 ]
    [ -f "${BATS_TEST_TMPDIR}/testenv.tar.gz" ]
    # Verify it's a valid gzip archive
    file "${BATS_TEST_TMPDIR}/testenv.tar.gz" | grep -q "gzip compressed"
}

@test "penv export: archive contains PENV_META" {
    if [[ ! -d "${VENV_STORAGE_DIR}/testenv/bin" ]]; then
        skip "python3 not available to create test env"
    fi
    cd "${BATS_TEST_TMPDIR}"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-export.sh" testenv
    tar -tzf "${BATS_TEST_TMPDIR}/testenv.tar.gz" | grep -q "PENV_META"
}

@test "penv export: archive contains env directory" {
    if [[ ! -d "${VENV_STORAGE_DIR}/testenv/bin" ]]; then
        skip "python3 not available to create test env"
    fi
    cd "${BATS_TEST_TMPDIR}"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-export.sh" testenv
    tar -tzf "${BATS_TEST_TMPDIR}/testenv.tar.gz" | grep -q "testenv/bin/python"
}

@test "penv export: rejects invalid name" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-export.sh" "../evil"
    [ "$status" -ne 0 ]
}
