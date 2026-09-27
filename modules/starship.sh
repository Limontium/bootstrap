#!/usr/bin/env bash

# ------------------------------------------------------------
# Starship
# ------------------------------------------------------------

install_starship() {
    info "Installing and configuring Starship"

    if command_exists starship; then
        ok "already installed: starship"
    else
        install_starship_binary
    fi

    install_starship_config

    ok "Starship configured"
}

install_starship_binary() {
    case "$DISTRO_FAMILY" in
        arch|macos)
            pkg_install starship
            ;;

        debian)
            install_starship_debian
            ;;

        *)
            install_starship_official
            ;;
    esac
}

install_starship_debian() {
    if apt-cache show starship >/dev/null 2>&1; then
        pkg_install starship
        return 0
    fi

    warn "Starship package is not available in the current APT repositories"
    install_starship_official
}

install_starship_official() {
    command_exists curl ||
        die "curl is required to install Starship"

    info "Installing Starship using official installer"

    curl -sS https://starship.rs/install.sh | sh -s -- -y

    command_exists starship ||
        die "Starship installation failed"

    ok "Installed Starship"
}

install_starship_config() {
    local source="${ROOT_DIR}/config/starship/starship.toml"
    local target="${HOME}/.config/starship.toml"

    [[ -f "$source" ]] ||
        die "Starship config not found: ${source}"

    copy_file "$source" "$target"
}
