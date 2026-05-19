set -g fish_greeting ""

if status is-interactive
    fastfetch -c small.jsonc
end

# Aliases
abbr -a ls 'eza --icons --group-directories-first'
abbr -a ll 'eza -la --icons --group-directories-first --git'
abbr -a tree 'eza --tree --icons'
abbr -a cat 'bat'
abbr -a afetch 'fastfetch -c small.jsonc'
abbr -a grep 'grep --color=auto'
abbr -a i 'sudo pacman -S'     
abbr -a pi 'paru -S'         
abbr -a rmv 'paru -Rns'      
# System Maintenance Cleanups
abbr -a clean-orphans 'pacman -Qtdq | xargs -r sudo pacman -Rns'
abbr -a clean-cache 'sudo pacman -Scc; and paru -Scc'
abbr -a clean-logs 'sudo journalctl --vacuum-time=7d'
abbr -a clean-user-cache 'rm -rf ~/.cache/*'
abbr -a sysclean 'pacman -Qtdq | xargs -r sudo pacman -Rns; and sudo pacman -Scc; and paru -Scc; and sudo journalctl --vacuum-time=7d; and rm -rf ~/.cache/*'
abbr -a ni 'npm install'         
abbr -a ns 'npm start'          
abbr -a nr 'npm run'
abbr -a nd 'npm run dev'     
abbr -a ff 'fastfetch'         
abbr -a af 'fastfetch -c small.jsonc'
abbr -a c 'clear'
abbr -a ex 'exit'
abbr -a gi 'git init'
abbr -a gs 'git status -s'
abbr -a ga 'git add --all'
abbr -a gp 'git push'
abbr -a gc 'git commit -m'
abbr -a gl 'git log --oneline --graph --all'
abbr -a gd 'git diff'
abbr -a gco 'git checkout'
abbr -a brave 'brave-origin-beta '

# Initials
zoxide init fish | source
starship init fish | source
fzf --fish | source

# 5. Global Variable for 'cd' -> 'z' behavior
alias cd='z'

# Keybindings
bind \t accept-autosuggestion
bind \b backward-kill-word 

# Custom Functions
function gac
    git add --all
    git commit -m "$argv"
end

function done
    git add --all
    git commit -m "$argv"
    git push
end
alias theme="bash ~/.config/hypr/scripts/theme.sh"

# --- MATUGEN COLOR SYNC ---
source ~/.config/fish/colors.fish

# --- FZF PREMIUM THEME ---
set -x FZF_DEFAULT_OPTS "--color=fg:-1,bg:-1,hl:$color_primary,fg+:-1,bg+:-1,hl+:$color_primary --color=info:$color_primary,prompt:$color_primary,pointer:$color_primary,marker:$color_primary,spinner:$color_primary,header:$color_primary --inline-info --height=40% --reverse --border=rounded"

# --- SUPER-JUMP (zoxide + fzf + eza preview) ---
function zi
    set -l result (zoxide query -i $argv)
    if test -n "$result"
        cd "$result"
    end
end

# Enhanced fzf directory search with eza preview
# Press CTRL+Alt+F to search files with a preview!
set -x FZF_DEFAULT_COMMAND "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git"
set -x FZF_CTRL_P_COMMAND "$FZF_DEFAULT_COMMAND"
set -x FZF_CTRL_P_OPTS "--preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"

bind \cp fzf-file-widget
