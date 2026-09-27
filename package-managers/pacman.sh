#!/usr/bin/env bash

# ------------------------------------------------------------
# Pacman backend
# ------------------------------------------------------------

pkg_update() {
    if [[ "$DISTRO" == "omarchy" ]] && command_exists omarchy; then
        info "Updating Omarchy system"
        omarchy update
        return 0
    fi

    info "Updating Arch package database and system"
    run_sudo pacman -Syu --noconfirm
}

pkg_install_backend() {
    local packages=("$@")
    local missing=()
    local package

    for package in "${packages[@]}"; do
        if pacman -Q "$package" >/dev/null 2>&1; then
            ok "already installed: ${package}"
        else
            missing+=("$package")
        fi
    done

    if ((${#missing[@]} == 0)); then
        return 0
    fi

    info "Installing packages via pacman: ${missing[*]}"
    run_sudo pacman -S --needed --noconfirm "${missing[@]}"
}
