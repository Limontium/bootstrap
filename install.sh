#!/usr/bin/env bash

set -euo pipefail

readonly ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# ------------------------------------------------------------
# Core
# ------------------------------------------------------------

source "${ROOT_DIR}/lib/core.sh"
source "${ROOT_DIR}/lib/detect.sh"
source "${ROOT_DIR}/lib/packages.sh"
source "${ROOT_DIR}/lib/package-map.sh"
source "${ROOT_DIR}/lib/verify.sh"

# ------------------------------------------------------------
# Modules
# ------------------------------------------------------------

source "${ROOT_DIR}/modules/base.sh"
source "${ROOT_DIR}/modules/git.sh"
source "${ROOT_DIR}/modules/zsh.sh"
source "${ROOT_DIR}/modules/starship.sh"
source "${ROOT_DIR}/modules/fonts.sh"
source "${ROOT_DIR}/modules/lazygit.sh"
source "${ROOT_DIR}/modules/yazi.sh"
source "${ROOT_DIR}/modules/neovim.sh"
source "${ROOT_DIR}/modules/nvim-config.sh"
source "${ROOT_DIR}/modules/ghostty.sh"

# ------------------------------------------------------------
# Entrypoint
# ------------------------------------------------------------

main() {
    info "Starting system bootstrap"

    detect_platform

    info "Detected distro: ${DISTRO}"
    info "Distro family: ${DISTRO_FAMILY}"
    info "Package manager: ${PKG_MANAGER}"

    load_package_manager

    install_base
    install_git
    install_zsh
    install_starship
    install_fonts
    install_lazygit
    install_yazi
    install_neovim
    install_nvim_config
    install_ghostty

    printf '\n'

    if ! verify_installation; then
        warn "Some tools are missing. Check the messages above."
    fi

    printf '\n'
    ok "System bootstrap complete"

    print_next_steps
    print_nvim_ssh_next_steps
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
