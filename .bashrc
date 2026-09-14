# If not running interactively, don't do anything
[[ $- != *i* ]] && return

fastfetch -c small.jsonc 2>/dev/null || true

# History configuration
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=10000
HISTFILESIZE=10000
shopt -s histappend
shopt -s checkwinsize

# Readline input configurations (search history with Up/Down arrow prefix)
bind '"\e[A": history-search-backward' 2>/dev/null || true
bind '"\e[B": history-search-forward' 2>/dev/null || true
bind '"\e[1;5D": backward-word' 2>/dev/null || true
bind '"\e[1;5C": forward-word' 2>/dev/null || true

# Aliases
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias tree='eza --tree --icons'
alias cat='bat'
alias afetch='fastfetch -c small.jsonc'
alias ff='fastfetch'
alias af='fastfetch -c small.jsonc'
alias grep='grep --color=auto'
alias i='sudo pacman -S'
alias pi='paru -S'
alias rmv='paru -Rns'
alias orphans='paru -Rns $(pacman -Qtdq)'
alias ni='npm install'
alias ns='npm start'
alias nr='npm run'
alias nd='npm run dev'
alias c='clear'
alias ex='exit'
alias gi='git init'
alias gs='git status -s'
alias ga='git add --all'
alias gp='git push'
alias gc='git commit -m'
alias gl='git log --oneline --graph --all'
alias gd='git diff'
alias gco='git checkout'
alias brave='brave-origin-beta'
alias cd='z'
alias theme="bash ~/.config/hypr/scripts/theme.sh"

# Docker Aliases
alias dkillall='docker ps -q | xargs -r docker kill'
alias drun='docker run --rm -it'
alias dcdown='docker compose down -v --remove-orphans'
alias dprune='docker system prune -a --volumes -f'

# Custom Functions
gac() {
    git add --all
    git commit -m "$*"
}

donee() {
    git add --all
    git commit -m "$*"
    git push
}

sysclean() {
    echo -e "\033[0;34m[1/4] Removing orphan packages...\033[0m"
    pacman -Qtdq | xargs -r sudo pacman -Rns

    echo -e "\n\033[0;34m[2/4] Cleaning package caches (pacman & paru)...\033[0m"
    paru -Scc --noconfirm
    sudo sh -c 'rm -rf /var/cache/pacman/pkg/download-*'

    echo -e "\n\033[0;34m[3/4] Vacuuming system logs (keeping 7 days)...\033[0m"
    sudo journalctl --vacuum-time=7d

    echo -e "\n\033[0;34m[4/4] Clearing user-space render cache (~/.cache)...\033[0m"
    rm -rf ~/.cache/*

    echo -e "\n\033[0;32m[SUCCESS] System cleanup completed successfully!\033[0m"
}

# Initializations
eval "$(zoxide init bash)"
eval "$(starship init bash)"

# Source FZF keybindings and completions
if [ -f /usr/share/fzf/key-bindings.bash ]; then
    source /usr/share/fzf/key-bindings.bash
fi
if [ -f /usr/share/fzf/completion.bash ]; then
    source /usr/share/fzf/completion.bash
fi

source ~/.config/zsh/colors.zsh 2>/dev/null || true

export FZF_DEFAULT_OPTS="--color=fg:-1,bg:-1,hl:$color_primary,fg+:-1,bg+:-1,hl+:$color_primary --color=info:$color_primary,prompt:$color_primary,pointer:$color_primary,marker:$color_primary,spinner:$color_primary,header:$color_primary --inline-info --height=40% --reverse --border=rounded"

zi() {
    local result
    result=$(zoxide query -i "$@")
    if [[ -n "$result" ]]; then
        cd "$result"
    fi
}

# Fzf Configuration
export FZF_DEFAULT_COMMAND="fd --type f --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --follow --exclude .git"

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons --color=always {}' --preview-window=right:50%"
export FZF_CTRL_R_OPTS="--preview 'echo {} | bat --color=always -p -l sh' --preview-window=down:3:wrap"

# Ctrl+P binds to file search preview
bind -x '"\C-p": fzf-file-widget' 2>/dev/null || true

# Yazi file manager wrapper
yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Fuzzy file editor using Vim
fe() {
    local file
    file=$(fzf --query="$1" --select-1 --exit-0 --preview 'bat -n --color=always {}')
    [ -n "$file" ] && vim "$file"
}

# Android & Flutter SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$HOME/development/flutter/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
