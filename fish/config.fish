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
abbr -a orphans 'paru -Rns (pacman -Qtdq)' 
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
