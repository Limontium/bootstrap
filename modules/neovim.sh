#!/usr/bin/env bash

# ------------------------------------------------------------
# Neovim
# ------------------------------------------------------------

install_neovim() {
    info "Installing Neovim and dependencies"

    if [[ "$DISTRO_FAMILY" == "debian" ]]; then
        configure_neovim_ppa
    fi

    pkg_install \
	    neovim \
	    build-tools \
	    ripgrep \
	    fd \
	    unzip \
	    curl \
	    ca-certificates \
	    nodejs

    install_neovim_platform_extras
    ensure_fd_command

    ok "Neovim dependencies installed"
}

configure_neovim_ppa() {
    if [[ "$DISTRO" != "ubuntu" ]]; then
        return 0
    fi

    if apt-cache policy neovim 2>/dev/null | grep -q 'neovim-ppa'; then
        ok "Neovim PPA already configured"
        return 0
    fi

    if ! command_exists add-apt-repository; then
        warn "add-apt-repository not found; using distro Neovim package"
        return 0
    fi

    info "Adding Neovim unstable PPA"

    if run_sudo add-apt-repository -y ppa:neovim-ppa/unstable; then
        pkg_update
    else
        warn "Failed to add Neovim PPA; using distro package"
    fi
}

install_neovim_platform_extras() {
    case "$DISTRO_FAMILY" in
        debian|arch)
            pkg_install \
                npm \
                xclip \
                wl-clipboard
            ;;

        alpine)
            # Alpine packages Node.js and npm separately.
            pkg_install npm
            ;;

        macos)
            # npm comes with Homebrew's node package.
            ;;

        *)
            # We'll add distro-specific extras when support is verified.
            ;;
    esac
}

ensure_fd_command() {
    if command_exists fd; then
        ok "fd command available"
        return 0
    fi

    if ! command_exists fdfind; then
        warn "Neither fd nor fdfind is available"
        return 0
    fi

    # Debian/Ubuntu package fd-find installs the binary as "fdfind".
    if command_exists update-alternatives; then
        info "Registering fdfind as fd"

        run_sudo update-alternatives \
            --install /usr/local/bin/fd fd /usr/bin/fdfind 100 \
            || true

        run_sudo update-alternatives \
            --set fd /usr/bin/fdfind \
            || true
    fi

    if command_exists fd; then
        ok "fd command available"
    else
        warn "fdfind is installed, but fd alias could not be configured"
    fi
}
