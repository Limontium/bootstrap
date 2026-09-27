#!/usr/bin/env bash

# ------------------------------------------------------------
# Lazygit
# ------------------------------------------------------------

readonly LAZYGIT_VERSION="0.65.1"

install_lazygit() {
    info "Installing Lazygit"

    if command_exists lazygit; then
        ok "already installed: lazygit"
        return 0
    fi

    case "$DISTRO_FAMILY" in
        arch|macos)
            pkg_install lazygit
            ;;
        *)
            install_lazygit_release
            ;;
    esac
}

install_lazygit_release() {
    local arch
    local target
    local checksum
    local url
    local tmp

    arch="$(uname -m)"

    case "$arch" in
        x86_64)
            target="x86_64"
            checksum="02beacbcda0fa342e50ae3480ba8147307353af3fb28e1d5f790e02329c201a6"
            ;;

        aarch64|arm64)
            target="arm64"
            checksum="49abecdf6adf4f2dfdb11bf7b9bfada267ea523612ed809d1c6d87f6c04000a7"
            ;;

        *)
            die "Unsupported architecture for Lazygit: ${arch}"
            ;;
    esac

    command_exists curl || die "curl is required to install Lazygit"
    command_exists tar || die "tar is required to install Lazygit"
    command_exists sha256sum || die "sha256sum is required to verify Lazygit"

    tmp="$(mktemp -d)"

    url="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_linux_${target}.tar.gz"

    info "Downloading Lazygit ${LAZYGIT_VERSION}"

    curl -fsSL \
        -o "${tmp}/lazygit.tar.gz" \
        "$url"

    if ! printf '%s  %s\n' \
        "$checksum" \
        "${tmp}/lazygit.tar.gz" \
        | sha256sum -c - >/dev/null; then

        rm -rf "$tmp"
        die "Checksum verification failed for Lazygit ${LAZYGIT_VERSION}"
    fi

    tar -xzf \
        "${tmp}/lazygit.tar.gz" \
        -C "$tmp" \
        lazygit

    run_sudo install \
        -m 0755 \
        "${tmp}/lazygit" \
        /usr/local/bin/lazygit

    rm -rf "$tmp"

    ok "Installed Lazygit ${LAZYGIT_VERSION}"
}
