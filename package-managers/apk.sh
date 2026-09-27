#!/usr/bin/env bash

# ------------------------------------------------------------
# APK backend
# ------------------------------------------------------------

pkg_update() {
    info "Updating APK package index"
    run_sudo apk update
}

pkg_install_backend() {
    local packages=("$@")
    local missing=()
    local package

    for package in "${packages[@]}"; do
        if apk info -e "$package" >/dev/null 2>&1; then
            ok "already installed: ${package}"
        else
            missing+=("$package")
        fi
    done

    if ((${#missing[@]} == 0)); then
        return 0
    fi

    info "Installing packages via APK: ${missing[*]}"
    run_sudo apk add "${missing[@]}"
}
