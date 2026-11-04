#!/usr/bin/env bash

install_posting() {
    info "Installing and configuring Posting"

    local bin_dir="${HOME}/.local/bin"
    export PATH="${bin_dir}:${PATH}"

    if command_exists posting; then
        ok "already installed: posting"
    else
        if ! command_exists uv; then
            install_posting_uv
        fi

        UV_TOOL_BIN_DIR="$bin_dir" uv tool install --python 3.13 posting
    fi

    install_posting_config
}

install_posting_uv() {
    command_exists curl || die "curl is required to install uv"

    local installer
    installer="$(mktemp)"

    if ! curl -fsSL https://astral.sh/uv/install.sh -o "$installer"; then
        rm -f "$installer"
        die "Failed to download the uv installer"
    fi

    if ! UV_INSTALL_DIR="${HOME}/.local/bin" UV_NO_MODIFY_PATH=1 sh "$installer"; then
        rm -f "$installer"
        die "Failed to install uv"
    fi

    rm -f "$installer"
}

install_posting_config() {
    local source="${ROOT_DIR}/config/posting/config.yaml"
    local target

    if [[ ! -f "$source" ]]; then
        warn "Posting config not found: ${source}; skipping configuration"
        return 0
    fi

    target="$(posting locate config)" || die "Failed to locate Posting config"
    target="${target##*$'\n'}"
    [[ "$target" == /* ]] || die "Posting returned an invalid config path: ${target}"

    copy_file "$source" "$target"
}
