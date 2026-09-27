# ---------------------------------------------------------
# Zinit
# ---------------------------------------------------------

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "${ZINIT_HOME:h}"
    git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "$ZINIT_HOME/zinit.zsh"

# ---------------------------------------------------------
# Environment
# ---------------------------------------------------------

export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"

export EDITOR="nvim"
export VISUAL="$EDITOR"

# ---------------------------------------------------------
# History
# ---------------------------------------------------------

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt appendhistory
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt sharehistory
setopt incappendhistory

# ---------------------------------------------------------
# Completion
# ---------------------------------------------------------

autoload -Uz compinit

ZCOMPDUMP_FILE="${ZDOTDIR:-$HOME}/.zcompdump"

if [[ -n "$ZCOMPDUMP_FILE"(#qN.mh+24) ]]; then
    compinit -d "$ZCOMPDUMP_FILE"
else
    compinit -C -d "$ZCOMPDUMP_FILE"
fi

# ---------------------------------------------------------
# Zinit plugins
# ---------------------------------------------------------

zinit snippet OMZP::sudo
zinit snippet OMZP::extract

zinit light zsh-users/zsh-autosuggestions

zinit ice wait lucid
zinit light Aloxaf/fzf-tab

zinit ice wait lucid
zinit light zsh-users/zsh-syntax-highlighting

# ---------------------------------------------------------
# History prefix search
# ---------------------------------------------------------

bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

# ---------------------------------------------------------
# Tools
# ---------------------------------------------------------

if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh --cmd cd)"
fi

if (( $+commands[starship] )); then
    eval "$(starship init zsh)"
fi

# ---------------------------------------------------------
# Aliases
# ---------------------------------------------------------

alias v="nvim"
alias c="clear"
alias y="yazi"
alias lg="lazygit"

alias g="git"
alias gst="git status"

alias ga="git add"
alias gaa="git add --all"

alias gcmsg="git commit -m"

alias gp="git push"
alias gpf="git push --force-with-lease"
alias gl="git pull"

git_default_branch() {
    git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null \
        | sed 's@^refs/remotes/origin/@@'
}

alias gcm='git switch $(git_default_branch)'
alias gco="git checkout"
alias gcb="git checkout -b"

alias gb="git branch"
alias gbD="git branch -D"

alias ls="eza --icons"
alias l="eza --icons"
alias ll="eza -l --icons --git --group-directories-first"
alias la="eza -la --icons --git"
alias lt="eza --tree --icons --level=2"
alias lta="eza --tree --icons --level=3 --all"
alias lsize="eza -l --sort=size --icons --group-directories-first"
alias ldate="eza -l --sort=modified --icons --group-directories-first"
