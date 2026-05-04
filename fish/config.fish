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
abbr -a remove 'paru -Rns'      
abbr -a orphans 'paru -Rns (pacman -Qtdq)' 
abbr -a ni 'npm install'         
abbr -a ns 'npm start'          
abbr -a nd 'npm run dev'     
abbr -a ff 'fastfetch'         
abbr -a af 'fastfetch -c small.jsonc'

# Initials
zoxide init fish | source
starship init fish | source
fzf --fish | source

# 5. Global Variable for 'cd' -> 'z' behavior
alias cd='z'

# Keybindings
bind \t accept-autosuggestion
bind \b backward-kill-word 
