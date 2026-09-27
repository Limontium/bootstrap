#!/usr/bin/env bash

# ------------------------------------------------------------
# Git
# ------------------------------------------------------------

install_git() {
    info "Configuring Git"

    if ! command_exists git; then
        pkg_install git
    fi

    git config --global pull.rebase false
    git config --global rerere.enabled true
    git config --global push.autoSetupRemote true
    git config --global merge.conflictStyle zdiff3
    git config --global diff.colorMoved true
    git config --global commit.verbose true
    git config --global core.editor "nvim"
    git config --global core.autocrlf input
    git config --global fetch.prune true

    ok "Git configured"
}
