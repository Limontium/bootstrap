#!/usr/bin/env bash

# ------------------------------------------------------------
# Yazi
# ------------------------------------------------------------

readonly YAZI_VERSION="26.9.1"

install_yazi() {
    info "Installing Yazi"

    if command_exists yazi; then
        ok "already installed: yazi"
        return 0
    fi

    case "$DISTRO_FAMILY" in
        arch|macos)
            pkg_install yazi
            ;;
        *)
            install_yazi_release
            ;;
    esac
}

install_yazi_release() {
    local arch
    local target
    local checksum
    local libc
    local url
    local tmp

    arch="$(uname -m)"

    # The musl build is portable across Alpine and older glibc-based Debian
    # releases whose libc is too old for the current GNU release artifact.
    if [[ "$DISTRO_FAMILY" == "alpine" || "$DISTRO_FAMILY" == "debian" ]]; then
        libc="musl"
    else
        libc="gnu"
    fi

    case "${arch}:${libc}" in
        x86_64:gnu)
            target="x86_64-unknown-linux-gnu"
            checksum="a02fe91d3304294048c681f010f1100856872a4e98ecf6927328e888d40a6ad2"
            ;;

        x86_64:musl)
            target="x86_64-unknown-linux-musl"
            checksum="9b9c39decccf8cb0ff53a7d637d38f8a79d93bbd0099f4ea9c619ef6bb392f5d"
            ;;

        aarch64:gnu|arm64:gnu)
            target="aarch64-unknown-linux-gnu"
            checksum="02807f08d6b589b65b7516a4e259d83f5995d7a23bb12b3a155141385b370b3a"
            ;;

        aarch64:musl|arm64:musl)
            target="aarch64-unknown-linux-musl"
            checksum="dd569daecaae914185f295634109295ccd25c1b42b02eb89a74f651970024f2e"
            ;;

        *)
            die "Unsupported architecture for Yazi: ${arch}"
            ;;
    esac

    command_exists curl || die "curl is required to install Yazi"
    command_exists unzip || die "unzip is required to install Yazi"
    command_exists sha256sum || die "sha256sum is required to verify Yazi"

    tmp="$(mktemp -d)"

    url="https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-${target}.zip"

    info "Downloading Yazi ${YAZI_VERSION}"

    curl -fsSL \
        -o "${tmp}/yazi.zip" \
        "$url"

    if ! printf '%s  %s\n' \
        "$checksum" \
        "${tmp}/yazi.zip" \
        | sha256sum -c - >/dev/null; then

        rm -rf "$tmp"
        die "Checksum verification failed for Yazi ${YAZI_VERSION}"
    fi

    unzip -qo \
        "${tmp}/yazi.zip" \
        -d "${tmp}/yazi"

    run_sudo install \
        -m 0755 \
        "${tmp}/yazi/yazi-${target}/yazi" \
        /usr/local/bin/yazi

    run_sudo install \
        -m 0755 \
        "${tmp}/yazi/yazi-${target}/ya" \
        /usr/local/bin/ya

    rm -rf "$tmp"

    ok "Installed Yazi ${YAZI_VERSION}"
}
