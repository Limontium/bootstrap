#!/usr/bin/env bash

# ------------------------------------------------------------
# Platform detection
# ------------------------------------------------------------

DISTRO=""
DISTRO_FAMILY=""
PKG_MANAGER=""

detect_platform() {
    local kernel
    kernel="$(uname -s)"

    case "$kernel" in
        Darwin)
            DISTRO="macos"
            DISTRO_FAMILY="macos"
            PKG_MANAGER="brew"
            ;;

        Linux)
            detect_linux
            ;;

        *)
            die "Unsupported operating system: ${kernel}"
            ;;
    esac
}

detect_linux() {
    [[ -r /etc/os-release ]] || die "Cannot detect Linux distribution: /etc/os-release not found"

    # shellcheck disable=SC1091
    source /etc/os-release

    DISTRO="${ID:-unknown}"

    case "${ID:-}" in
        arch|endeavouros|manjaro|omarchy)
            DISTRO_FAMILY="arch"
            PKG_MANAGER="pacman"
            ;;

        ubuntu|debian|pop|linuxmint|zorin|elementary)
            DISTRO_FAMILY="debian"
            PKG_MANAGER="apt"
            ;;

        fedora|rhel|centos|rocky|almalinux)
            DISTRO_FAMILY="fedora"
            PKG_MANAGER="dnf"
            ;;

        opensuse*|sles)
            DISTRO_FAMILY="suse"
            PKG_MANAGER="zypper"
            ;;

        alpine)
            DISTRO_FAMILY="alpine"
            PKG_MANAGER="apk"
            ;;

        *)
            detect_linux_fallback
            ;;
    esac
}

detect_linux_fallback() {
    local id_like="${ID_LIKE:-}"

    case " ${id_like} " in
        *" arch "*)
            DISTRO_FAMILY="arch"
            PKG_MANAGER="pacman"
            return 0
            ;;

        *" debian "*|*" ubuntu "*)
            DISTRO_FAMILY="debian"
            PKG_MANAGER="apt"
            return 0
            ;;

        *" fedora "*|*" rhel "*)
            DISTRO_FAMILY="fedora"
            PKG_MANAGER="dnf"
            return 0
            ;;

        *" suse "*)
            DISTRO_FAMILY="suse"
            PKG_MANAGER="zypper"
            return 0
            ;;
    esac

    detect_package_manager
}

detect_package_manager() {
    if command_exists apt-get; then
        DISTRO_FAMILY="debian"
        PKG_MANAGER="apt"

    elif command_exists pacman; then
        DISTRO_FAMILY="arch"
        PKG_MANAGER="pacman"

    elif command_exists dnf; then
        DISTRO_FAMILY="fedora"
        PKG_MANAGER="dnf"

    elif command_exists zypper; then
        DISTRO_FAMILY="suse"
        PKG_MANAGER="zypper"

    elif command_exists apk; then
        DISTRO_FAMILY="alpine"
        PKG_MANAGER="apk"

    else
        die "Unsupported Linux distribution or package manager: ${DISTRO}"
    fi
}
