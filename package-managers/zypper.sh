#!/usr/bin/env bash

# ------------------------------------------------------------
# Zypper backend
# ------------------------------------------------------------

pkg_update() {
    info "Refreshing Zypper repositories"
    run_sudo zypper --non-interactive refresh
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

    info "Installing packages via Zypper: ${missing[*]}"
    run_sudo zypper --non-interactive install "${missing[@]}"
}
