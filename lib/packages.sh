#!/usr/bin/env bash

# ------------------------------------------------------------
# Package manager loader
# ------------------------------------------------------------

load_package_manager() {
    local backend="${ROOT_DIR}/package-managers/${PKG_MANAGER}.sh"

    [[ -f "$backend" ]] || die "Package manager backend not found: ${backend}"

    # shellcheck disable=SC1090
    source "$backend"

    declare -F pkg_install_backend >/dev/null ||
        die "Package manager backend '${PKG_MANAGER}' does not implement pkg_install_backend()"

    declare -F pkg_update >/dev/null ||
        die "Package manager backend '${PKG_MANAGER}' does not implement pkg_update()"

    ok "Loaded package manager backend: ${PKG_MANAGER}"
}

# ------------------------------------------------------------
# Package helpers
# ------------------------------------------------------------

pkg_install() {
    local logical_packages=("$@")
    local resolved_packages=()
    local package
    local resolved

    for package in "${logical_packages[@]}"; do
        resolved="$(pkg_name "$package")"
        resolved_packages+=("$resolved")
    done

    pkg_install_backend "${resolved_packages[@]}"
}

pkg_install_if_missing() {
    local command="$1"
    local package="${2:-$1}"

    if command_exists "$command"; then
        ok "already installed: ${command}"
        return 0
    fi

    pkg_install "$package"
}
