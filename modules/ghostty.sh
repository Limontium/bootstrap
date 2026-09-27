#!/usr/bin/env bash

# ------------------------------------------------------------
# Ghostty
# ------------------------------------------------------------

install_ghostty() {
    info "Installing and configuring Ghostty"

    if command_exists ghostty; then
        ok "already installed: ghostty"
    else
        install_ghostty_package
    fi

    if command_exists ghostty; then
        install_ghostty_config
        configure_default_terminal
        ok "Ghostty configured"
    else
        warn "Ghostty is not installed; skipping configuration"
    fi
}

install_ghostty_package() {
    case "$DISTRO_FAMILY" in
        arch)
            pkg_install ghostty
            ;;

        macos)
            pkg_install_cask ghostty
            ;;

        debian)
            install_ghostty_debian
            ;;

        *)
            warn "Automatic Ghostty installation is not implemented for ${DISTRO_FAMILY}"
            return 0
            ;;
    esac
}

install_ghostty_debian() {
    if [[ "$DISTRO" != "ubuntu" ]]; then
        warn "Automatic Ghostty installation is currently supported only for Ubuntu"
        return 0
    fi

    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
    fi

    if command_exists dpkg &&
        dpkg --compare-versions "${VERSION_ID:-0}" ge "26.04"; then

        info "Installing Ghostty from Ubuntu repository"
        pkg_install ghostty
        return 0
    fi

    command_exists curl ||
        die "curl is required to install Ghostty"

    info "Installing Ghostty using Ubuntu community installer"

    /bin/bash -c "$(
        curl -fsSL \
            https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh
    )"

    if ! command_exists ghostty; then
        warn "Ghostty installation did not succeed"
        return 0
    fi

    ok "Ghostty installed"
}

install_ghostty_config() {
    local source="${ROOT_DIR}/config/ghostty/config"
    local target="${HOME}/.config/ghostty/config"

    [[ -f "$source" ]] ||
        die "Ghostty config not found: ${source}"

    copy_file "$source" "$target"
}

configure_default_terminal() {
    case "$DISTRO_FAMILY" in
        macos)
            return 0
            ;;

        *)
            configure_default_terminal_linux
            ;;
    esac
}

configure_default_terminal_linux() {
    local source="${ROOT_DIR}/config/ghostty/xdg-terminals.list"
    local target="${HOME}/.config/xdg-terminals.list"

    if [[ -f "$source" ]]; then
        copy_file "$source" "$target"
    else
        warn "XDG terminal config not found: ${source}"
    fi

    if [[ "$DISTRO_FAMILY" == "arch" ]] && command_exists omarchy; then
        info "Setting Ghostty as Omarchy default terminal"

        if omarchy default terminal ghostty; then
            ok "Ghostty is now the Omarchy default terminal"
        else
            warn "Unable to set Ghostty through Omarchy CLI"
        fi

        return 0
    fi

    if [[ "$DISTRO_FAMILY" == "debian" ]] &&
        command_exists update-alternatives; then

        configure_debian_terminal_alternative
    fi
}

configure_debian_terminal_alternative() {
    local ghostty_path
    ghostty_path="$(command -v ghostty)"

    [[ -n "$ghostty_path" ]] || return 0

    if update-alternatives \
        --query x-terminal-emulator 2>/dev/null \
        | grep -F "Alternative: ${ghostty_path}" >/dev/null; then

        run_sudo update-alternatives \
            --set x-terminal-emulator \
            "$ghostty_path"

        ok "Ghostty set as x-terminal-emulator"
    else
        warn "Ghostty is not registered as an x-terminal-emulator alternative"
    fi
}
