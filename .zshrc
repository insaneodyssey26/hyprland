if [[ -o interactive ]]; then
    fastfetch -c small.jsonc 2>/dev/null || true
fi

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# Prefix search history with Up/Down arrows
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# Home, End, Ctrl+Left, Ctrl+Right key bindings
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line

bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word


# Load Zsh plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null || true
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null || true

bindkey '^I' autosuggest-accept
bindkey '^?' backward-delete-char
bindkey '^H' backward-kill-word

# Fish-style Abbreviations
typeset -A abbreviations
abbreviations=(
    ls      'eza --icons --group-directories-first'
    ll      'eza -la --icons --group-directories-first --git'
    tree    'eza --tree --icons'
    cat     'bat'
    afetch  'fastfetch -c small.jsonc'
    grep    'grep --color=auto'
    i       'sudo pacman -S'     
    pi      'paru -S'         
    rmv     'paru -Rns'      
    orphans 'paru -Rns $(pacman -Qtdq)' 
    ni      'npm install'         
    ns      'npm start'          
    nr      'npm run'
    nd      'npm run dev'     
    ff      'fastfetch'         
    af      'fastfetch -c small.jsonc'
    c       'clear'
    ex      'exit'
    gi      'git init'
    gs      'git status -s'
    ga      'git add --all'
    gp      'git push'
    gc      'git commit -m'
    gl      'git log --oneline --graph --all'
    gd      'git diff'
    gco     'git checkout'
    brave   'brave-origin-beta '

    # Docker
    dkillall 'docker ps -q | xargs -r docker kill'           # Instantly kill all running containers
    drun     'docker run --rm -it'                           # Run container with auto-cleanup (--rm)
    dcdown   'docker compose down -v --remove-orphans'       # Safe teardown (remove volumes/networks)
    dprune   'docker system prune -a --volumes -f'           # Deep prune (wipe images, cache, volumes)
)


expand-abbreviation() {
    if [[ "$LBUFFER" =~ '[a-zA-Z0-9_-]+$' ]]; then
        local words=(${(z)LBUFFER})
        local last_word="${words[-1]}"
        if [[ -n "${abbreviations[$last_word]}" ]]; then
            local is_cmd=0
            if (( $#words <= 1 )); then
                is_cmd=1
            else
                local prev_word="${words[-2]}"
                case "$prev_word" in
                    ";"|"&&"|"||"|"|"|"sudo") is_cmd=1 ;;
                esac
            fi
            if (( is_cmd )); then
                LBUFFER="${LBUFFER%${last_word}}${abbreviations[$last_word]}"
            fi
        fi
    fi
}

expand-abbreviation-and-space() {
    expand-abbreviation
    zle self-insert
}

expand-abbreviation-and-accept() {
    expand-abbreviation
    zle accept-line
}

zle -N expand-abbreviation-and-space
zle -N expand-abbreviation-and-accept

bindkey ' ' expand-abbreviation-and-space
bindkey '^M' expand-abbreviation-and-accept
bindkey '^ ' self-insert

alias cd='z'

# Initializations
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
source /usr/share/fzf/completion.zsh 2>/dev/null || true
source /usr/share/fzf/key-bindings.zsh 2>/dev/null || true

# Custom Functions
gac() {
    git add --all
    git commit -m "$*"
}

# Renamed from 'done' to prevent Zsh syntax error
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

alias theme="bash ~/.config/hypr/scripts/theme.sh"

source ~/.config/zsh/colors.zsh 2>/dev/null || true

export FZF_DEFAULT_OPTS="--color=fg:-1,bg:-1,hl:$color_primary,fg+:-1,bg+:-1,hl+:$color_primary --color=info:$color_primary,prompt:$color_primary,pointer:$color_primary,marker:$color_primary,spinner:$color_primary,header:$color_primary --inline-info --height=40% --reverse --border=rounded"

zi() {
    local result
    result=$(zoxide query -i "$@")
    if [[ -n "$result" ]]; then
        cd "$result"
    fi
}

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# Ctrl+P binds to file search preview (since Kitty uses Ctrl+T for new tabs)
bindkey '^P' fzf-file-widget
