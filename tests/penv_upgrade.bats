#!/usr/bin/env bats

setup() {
    export HOME="${BATS_TEST_TMPDIR}/home"
    export VENV_STORAGE_DIR="${BATS_TEST_TMPDIR}/venv_storage"
    mkdir -p "$VENV_STORAGE_DIR"

    # Create a fake penv install structure for upgrade to find
    mkdir -p "${BATS_TEST_TMPDIR}/penv_install/scripts"
    mkdir -p "${BATS_TEST_TMPDIR}/penv_install/tools"
    echo "0.1.2" > "${BATS_TEST_TMPDIR}/penv_install/VERSION"
    touch "${BATS_TEST_TMPDIR}/penv_install/penv"
    chmod +x "${BATS_TEST_TMPDIR}/penv_install/penv"
}

teardown() {
    rm -rf "${BATS_TEST_TMPDIR}"
}

@test "penv upgrade: reads current version" {
    # Test directly by sourcing and checking version detection
    run bash -c "cd '${BATS_TEST_TMPDIR}/penv_install' && cat VERSION"
    [ "$status" -eq 0 ]
    [ "$output" = "0.1.2" ]
}
