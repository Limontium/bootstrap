#!/usr/bin/env bash

# ------------------------------------------------------------
# Fonts
# ------------------------------------------------------------

readonly LILEX_NERD_FONT_VERSION="3.5.1"
readonly LILEX_NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v${LILEX_NERD_FONT_VERSION}/Lilex.zip"
readonly LILEX_NERD_FONT_CHECKSUM="07645c3a839fa8f74e8555c6c1c45187bf27d49fb27410992715f124311609e4"

install_fonts() {
    info "Installing fonts"

    case "$DISTRO_FAMILY" in
        macos)
            install_lilex_nerd_font_macos
            ;;
        *)
            install_lilex_nerd_font_linux
            ;;
    esac
}

install_lilex_nerd_font_linux() {
    local font_name="Lilex Nerd Font"
    local font_dir="${HOME}/.local/share/fonts"
    local tmp

    if fc-list 2>/dev/null | grep -Ei 'Lilex.*Nerd.*Font' >/dev/null; then
        ok "already installed: ${font_name}"
        return 0
    fi

    command_exists curl || die "curl is required to install ${font_name}"
    command_exists unzip || die "unzip is required to install ${font_name}"
    command_exists sha256sum || die "sha256sum is required to verify ${font_name}"

    tmp="$(mktemp -d)"

    info "Downloading ${font_name} ${LILEX_NERD_FONT_VERSION}"

    curl -fsSL \
        -o "${tmp}/Lilex.zip" \
        "$LILEX_NERD_FONT_URL"

    if ! printf '%s  %s\n' \
        "$LILEX_NERD_FONT_CHECKSUM" \
        "${tmp}/Lilex.zip" \
        | sha256sum -c - >/dev/null; then

        rm -rf "$tmp"
        die "Checksum verification failed for ${font_name}"
    fi

    mkdir -p "$font_dir"

    unzip -qo \
        "${tmp}/Lilex.zip" \
        -d "${tmp}/fonts"

    find "${tmp}/fonts" \
        -type f \
        \( -iname '*.ttf' -o -iname '*.otf' \) \
        -exec cp -f {} "$font_dir/" \;

    fc-cache -f "$font_dir" >/dev/null 2>&1 || true

    rm -rf "$tmp"

    ok "Installed ${font_name}"
}

install_lilex_nerd_font_macos() {
    if brew list --cask font-lilex-nerd-font >/dev/null 2>&1; then
        ok "already installed: Lilex Nerd Font"
        return 0
    fi

    pkg_install_cask font-lilex-nerd-font

    ok "Installed Lilex Nerd Font"
}
