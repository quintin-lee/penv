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

@test "penv plugin: shows help when no plugins dir" {
    run "${BATS_TEST_DIRNAME}/../scripts/penv-plugin.sh"
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "No plugins directory"
}

@test "penv plugin: lists no plugins when dir empty" {
    mkdir -p "${HOME}/.config/penv/plugins"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-plugin.sh"
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "No plugins installed"
}

@test "penv plugin: lists installed plugins" {
    mkdir -p "${HOME}/.config/penv/plugins"
    printf "#!/usr/bin/env bash\necho hello\n" > "${HOME}/.config/penv/plugins/hello.sh"
    chmod +x "${HOME}/.config/penv/plugins/hello.sh"
    run "${BATS_TEST_DIRNAME}/../scripts/penv-plugin.sh"
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "hello"
}
