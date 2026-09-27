#!/usr/bin/env bash

# ------------------------------------------------------------
# DNF backend
# ------------------------------------------------------------

pkg_update() {
    info "Refreshing DNF metadata"
    run_sudo dnf makecache -y
}

pkg_install_backend() {
    local packages=("$@")
    local missing=()
    local package

    for package in "${packages[@]}"; do
        if rpm -q "$package" >/dev/null 2>&1; then
            ok "already installed: ${package}"
        else
            missing+=("$package")
        fi
    done

    if ((${#missing[@]} == 0)); then
        return 0
    fi

    info "Installing packages via DNF: ${missing[*]}"
    run_sudo dnf install -y "${missing[@]}"
}
