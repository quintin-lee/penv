# setup.bash — Shared setup/teardown for penv bats tests
#
# Source this from .bats files to get:
#   - Isolated VENV_STORAGE_DIR per test
#   - fake_env() helper to create minimal environment dirs
#   - check_python3() helper for create tests

setup() {
    export VENV_STORAGE_DIR="${BATS_TEST_TMPDIR}/venv_storage"
    mkdir -p "$VENV_STORAGE_DIR"
}

teardown() {
    rm -rf "${VENV_STORAGE_DIR}"
}

# Create a minimal fake virtual environment directory structure
# (no real python involved — just enough to survive list/remove commands)
fake_env() {
    local name="$1"
    mkdir -p "${VENV_STORAGE_DIR}/${name}/bin"
    touch "${VENV_STORAGE_DIR}/${name}/bin/python"
}

# Like fake_env but also writes a description.txt
fake_env_with_desc() {
    local name="$1" desc="$2"
    fake_env "$name"
    printf "%s\n" "$desc" > "${VENV_STORAGE_DIR}/${name}/description.txt"
}

# Skip test if python3 is not available (for create tests)
check_python3() {
    if ! command -v python3 &>/dev/null; then
        skip "python3 is not installed"
    fi
}
