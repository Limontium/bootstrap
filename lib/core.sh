#!/usr/bin/env bash

# ------------------------------------------------------------
# Logging
# ------------------------------------------------------------

info() {
    printf '\033[1;34m==>\033[0m %s\n' "$*"
}

ok() {
    printf '\033[1;32mok\033[0m %s\n' "$*"
}

warn() {
    printf '\033[1;33mwarn\033[0m %s\n' "$*" >&2
}

die() {
    printf '\033[1;31merror\033[0m %s\n' "$*" >&2
    exit 1
}

# ------------------------------------------------------------
# Common helpers
# ------------------------------------------------------------

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

run_sudo() {
    info "(sudo) $*"
    sudo "$@"
}

ensure_dir() {
    local dir="$1"

    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
    fi
}

backup_file() {
    local file="$1"

    [[ -e "$file" || -L "$file" ]] || return 0

    local backup
    backup="${file}.bak.$(date +%Y%m%d_%H%M%S)"

    info "Backing up ${file} -> ${backup}"
    cp -a "$file" "$backup"
}

copy_file() {
    local source="$1"
    local target="$2"

    [[ -f "$source" ]] || die "Source file not found: ${source}"

    ensure_dir "$(dirname "$target")"

    if [[ -f "$target" ]] && ! [[ -L "$target" ]] && cmp -s "$source" "$target"; then
        ok "already up to date: ${target}"
        return 0
    fi

    if [[ -e "$target" || -L "$target" ]]; then
        backup_file "$target"
        rm -rf "$target"
    fi

    cp "$source" "$target"

    ok "installed: ${target}"
}
