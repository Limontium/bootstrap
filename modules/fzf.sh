#!/usr/bin/env bash

readonly FZF_VERSION="0.74.5"

install_fzf() {
    info "Installing fzf"

    case "$DISTRO_FAMILY" in
        arch|macos)
            pkg_install fzf
            return 0
            ;;
    esac

    local installed_version
    if command_exists fzf; then
        installed_version="$(fzf --version)"
        installed_version="${installed_version%% *}"
        if [[ "$(printf '%s\n' "$FZF_VERSION" "$installed_version" | sort -V | head -n 1)" == "$FZF_VERSION" ]]; then
            ok "already installed: fzf ${installed_version}"
            return 0
        fi
    fi

    install_fzf_release
}

install_fzf_release() (
    local arch target checksum tmp url
    arch="$(uname -m)"

    case "$arch" in
        x86_64)
            target="amd64"
            checksum="d47d7f882972c7d674dbbba998ffa4116e68379616ffac7695d0671e9a722c5f"
            ;;
        aarch64|arm64)
            target="arm64"
            checksum="cf058001da21724a469b714a29cf4aab9cbe860d218a0d6c1b5b661efad7784c"
            ;;
        *)
            die "Unsupported architecture for fzf: ${arch}"
            ;;
    esac

    command_exists curl || die "curl is required to install fzf"
    command_exists tar || die "tar is required to install fzf"
    command_exists sha256sum || die "sha256sum is required to verify fzf"

    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    url="https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_${target}.tar.gz"

    info "Downloading fzf ${FZF_VERSION}"
    curl -fsSL -o "${tmp}/fzf.tar.gz" "$url" || die "Failed to download fzf"

    if ! printf '%s  %s\n' "$checksum" "${tmp}/fzf.tar.gz" | sha256sum -c - >/dev/null; then
        die "Checksum verification failed for fzf ${FZF_VERSION}"
    fi

    tar -xzf "${tmp}/fzf.tar.gz" -C "$tmp" fzf || die "Failed to extract fzf"
    run_sudo install -m 0755 "${tmp}/fzf" /usr/local/bin/fzf || die "Failed to install fzf"

    ok "Installed fzf ${FZF_VERSION}"
)
