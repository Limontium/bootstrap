#!/usr/bin/env bash

# ------------------------------------------------------------
# Neovim config
# ------------------------------------------------------------

readonly NVIM_CONFIG_REPO="git@gitlab.com:ukondoby/nvim.git"
readonly NVIM_CONFIG_DIR="${HOME}/.config/nvim"

NVIM_SSH_SETUP_REQUIRED=0
NVIM_SSH_PUBLIC_KEY=""

install_nvim_config() {
    info "Installing Neovim configuration"

    if ! ensure_git_ssh_access; then
        warn "Skipping Neovim config clone until GitLab SSH access is configured"
        return 0
    fi

    if [[ -d "${NVIM_CONFIG_DIR}/.git" ]]; then
        update_nvim_config
        return 0
    fi

    if [[ -e "$NVIM_CONFIG_DIR" ]]; then
        backup_existing_nvim_config
    fi

    clone_nvim_config
}

update_nvim_config() {
    local current_remote

    current_remote="$(
        git -C "$NVIM_CONFIG_DIR" remote get-url origin 2>/dev/null || true
    )"

    if [[ "$current_remote" != "$NVIM_CONFIG_REPO" ]]; then
        warn "Existing Neovim config points to a different repository"
        backup_existing_nvim_config
        clone_nvim_config
        return 0
    fi

    info "Updating existing Neovim configuration"

    if git -C "$NVIM_CONFIG_DIR" diff --quiet &&
       git -C "$NVIM_CONFIG_DIR" diff --cached --quiet; then

        git -C "$NVIM_CONFIG_DIR" pull --ff-only
        ok "Neovim configuration updated"
    else
        warn "Neovim config has local changes; skipping git pull"
    fi
}

clone_nvim_config() {
    ensure_dir "$(dirname "$NVIM_CONFIG_DIR")"

    info "Cloning Neovim configuration"

    git clone \
        "$NVIM_CONFIG_REPO" \
        "$NVIM_CONFIG_DIR"

    ok "Neovim configuration installed"
}

backup_existing_nvim_config() {
    local backup

    backup="${NVIM_CONFIG_DIR}.bak.$(date +%Y%m%d_%H%M%S)"

    info "Backing up existing Neovim config -> ${backup}"

    mv "$NVIM_CONFIG_DIR" "$backup"
}

ensure_git_ssh_access() {
    command_exists ssh ||
        die "ssh is required to access the private Neovim repository"

    ensure_ssh_key

    info "Checking GitLab SSH access"

    local output

    set +e

    output="$(
        ssh \
            -o BatchMode=yes \
            -o StrictHostKeyChecking=accept-new \
            -T git@gitlab.com 2>&1
    )"

    set -e

    if [[ "$output" == *"Welcome to GitLab"* ]]; then
        ok "GitLab SSH access is configured"
        return 0
    fi

    NVIM_SSH_SETUP_REQUIRED=1

    if [[ -z "${NVIM_SSH_PUBLIC_KEY:-}" ]]; then
        if [[ -f "${HOME}/.ssh/id_ed25519.pub" ]]; then
            NVIM_SSH_PUBLIC_KEY="$(cat "${HOME}/.ssh/id_ed25519.pub")"
        elif [[ -f "${HOME}/.ssh/id_rsa.pub" ]]; then
            NVIM_SSH_PUBLIC_KEY="$(cat "${HOME}/.ssh/id_rsa.pub")"
        fi
    fi

    warn "GitLab SSH access is not configured yet"
    return 1
}

ensure_ssh_key() {
    local private_key=""
    local public_key=""

    if [[ -f "${HOME}/.ssh/id_ed25519" ]]; then
        private_key="${HOME}/.ssh/id_ed25519"
        public_key="${private_key}.pub"

    elif [[ -f "${HOME}/.ssh/id_rsa" ]]; then
        private_key="${HOME}/.ssh/id_rsa"
        public_key="${private_key}.pub"

    else
        info "No SSH key found; generating ed25519 key"

        mkdir -p "${HOME}/.ssh"
        chmod 700 "${HOME}/.ssh"

        private_key="${HOME}/.ssh/id_ed25519"
        public_key="${private_key}.pub"

        ssh-keygen \
            -t ed25519 \
            -f "$private_key" \
            -N "" \
            -C "$(whoami)@$(hostname)"

        ok "Generated SSH key: ${private_key}"
    fi

    if [[ ! -f "$public_key" ]]; then
        info "Generating public key from ${private_key}"

        ssh-keygen -y -f "$private_key" > "$public_key"
        chmod 644 "$public_key"
    fi

    NVIM_SSH_PUBLIC_KEY="$(cat "$public_key")"
}

print_nvim_ssh_next_steps() {
    if ((NVIM_SSH_SETUP_REQUIRED == 0)); then
        return 0
    fi

    printf '\n'
    printf '\033[1;33m--- GitLab SSH setup required ---\033[0m\n\n'

    printf '%s\n' \
        "Neovim config was not cloned because the SSH key is not registered in GitLab." \
        "" \
        "Add this public key to GitLab:" \
        ""

    if [[ -n "${NVIM_SSH_PUBLIC_KEY:-}" ]]; then
        printf '%s\n' "$NVIM_SSH_PUBLIC_KEY"
    else
        warn "Unable to determine SSH public key"
    fi

    printf '\n%s\n' \
        "Add the key here:" \
        "  https://gitlab.com/-/user_settings/ssh_keys" \
        "" \
        "After adding the key, run the installer again."
}
