# ---------------------------------------------------------
# Pinned shell plugins
# ---------------------------------------------------------

PLUGIN_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/shell-plugins"
PINNED_REPO_DIR=""

ensure_pinned_repo() {
    local repo_url="$1"
    local name="$2"
    local commit="$3"
    local current_commit=""

    PINNED_REPO_DIR="${PLUGIN_HOME}/${name}"

    if [[ -e "$PINNED_REPO_DIR" && ! -d "${PINNED_REPO_DIR}/.git" ]]; then
        print -u2 "plugin path exists but is not a Git repository: ${PINNED_REPO_DIR}"
        return 1
    fi

    if [[ ! -d "${PINNED_REPO_DIR}/.git" ]]; then
        mkdir -p "$PINNED_REPO_DIR"
        git -C "$PINNED_REPO_DIR" init -q || return 1
        git -C "$PINNED_REPO_DIR" remote add origin "$repo_url" || return 1
    else
        git -C "$PINNED_REPO_DIR" remote set-url origin "$repo_url" || return 1
        current_commit="$(git -C "$PINNED_REPO_DIR" rev-parse HEAD 2>/dev/null)"
    fi

    if [[ "$current_commit" != "$commit" ]]; then
        git -C "$PINNED_REPO_DIR" fetch --quiet --depth=1 origin "$commit" ||
            return 1
        git -C "$PINNED_REPO_DIR" checkout --quiet --detach --force FETCH_HEAD ||
            return 1
        current_commit="$(git -C "$PINNED_REPO_DIR" rev-parse HEAD 2>/dev/null)"
    fi

    if [[ "$current_commit" != "$commit" ]]; then
        print -u2 "commit verification failed for ${name}"
        return 1
    fi
}

# ---------------------------------------------------------
# Environment
# ---------------------------------------------------------

export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"

export EDITOR="nvim"
export VISUAL="$EDITOR"

# ---------------------------------------------------------
# Zsh options
# ---------------------------------------------------------

setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP

# ---------------------------------------------------------
# History
# ---------------------------------------------------------

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE

# ---------------------------------------------------------
# Completion
# ---------------------------------------------------------

autoload -Uz compinit

ZCOMPDUMP="${ZDOTDIR:-$HOME}/.zcompdump"

if [[ -n "$ZCOMPDUMP"(#qN.mh-24) ]]; then
    compinit -C -d "$ZCOMPDUMP"
else
    compinit -d "$ZCOMPDUMP"
fi

if [[ -s "$ZCOMPDUMP" &&
      (! -s "$ZCOMPDUMP.zwc" || "$ZCOMPDUMP" -nt "$ZCOMPDUMP.zwc") ]]; then
    zcompile "$ZCOMPDUMP"
fi

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# ---------------------------------------------------------
# Plugins locked to reviewed commits
# ---------------------------------------------------------

if ensure_pinned_repo \
    https://github.com/ohmyzsh/ohmyzsh.git \
    ohmyzsh \
    60c9a7a839b790cd905d0fd4419435124fd1bdc0; then

    ZSH="$PINNED_REPO_DIR"
    source "${PINNED_REPO_DIR}/plugins/sudo/sudo.plugin.zsh"
    source "${PINNED_REPO_DIR}/plugins/extract/extract.plugin.zsh"
fi

if ensure_pinned_repo \
    https://github.com/Aloxaf/fzf-tab.git \
    fzf-tab \
    24105b15714bfec37989ed5c5b6e60f572253019; then

    source "${PINNED_REPO_DIR}/fzf-tab.plugin.zsh"
fi

if ensure_pinned_repo \
    https://github.com/zsh-users/zsh-autosuggestions.git \
    zsh-autosuggestions \
    85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5; then

    source "${PINNED_REPO_DIR}/zsh-autosuggestions.zsh"
fi

if ensure_pinned_repo \
    https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
    fast-syntax-highlighting \
    4672ad5dd9ad68a7effc1476d65afb7c584ce2b3; then

    source "${PINNED_REPO_DIR}/fast-syntax-highlighting.plugin.zsh"
fi

# ---------------------------------------------------------
# fzf-tab
# ---------------------------------------------------------

zstyle ':fzf-tab:*' fzf-flags --height=50% --border
zstyle ':fzf-tab:*' switch-group ',' '.'

if (( $+commands[eza] )); then
    zstyle ':fzf-tab:complete:cd:*' \
        fzf-preview 'eza -1 --icons --color=always $realpath 2>/dev/null'
else
    zstyle ':fzf-tab:complete:cd:*' \
        fzf-preview 'ls -la $realpath 2>/dev/null'
fi

# ---------------------------------------------------------
# History prefix search
# ---------------------------------------------------------

autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

WORDCHARS='*?[]~=&;!#$%^(){}<>'

bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search

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
# General aliases
# ---------------------------------------------------------

alias v="nvim"
alias c="clear"

(( $+commands[yazi] )) && alias y="yazi"
(( $+commands[lazygit] )) && alias lg="lazygit"
if (( $+commands[ddgr] )); then
    alias d="ddgr"
    alias в="ddgr"
fi

# ---------------------------------------------------------
# Git aliases
# ---------------------------------------------------------

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
alias gcb="git switch -c"

alias gb="git branch"
alias gbD="git branch -D"

# ---------------------------------------------------------
# eza aliases
# ---------------------------------------------------------

if (( $+commands[eza] )); then
    alias ls="eza --icons"
    alias l="eza --icons"

    alias ll="eza -l --icons --git --group-directories-first"
    alias la="eza -la --icons --git"

    alias lt="eza --tree --icons --level=2"
    alias lta="eza --tree --icons --level=3 --all"

    alias lsize="eza -l --sort=size --icons --group-directories-first"
    alias ldate="eza -l --sort=modified --icons --group-directories-first"
else
    alias ll="ls -lah"
    alias la="ls -la"
fi
