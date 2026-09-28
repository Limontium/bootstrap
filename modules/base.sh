#!/usr/bin/env bash

install_base() {
    info "Installing base system packages"

    pkg_update

    pkg_install \
        git \
        curl \
        unzip \
        fontconfig \
        zoxide \
        eza \
        btop \
        jq \
        ffmpegthumbnailer \
        poppler \
        imagemagick \
        7zip \
        fzf

    ok "Base system packages installed"
}
