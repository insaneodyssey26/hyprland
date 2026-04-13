set -g fish_greeting ""

# 1. Startup Visuals
if status is-interactive
    # Runs your specific small config on startup
    fastfetch -c small.jsonc
end

# 2. Modern Aliases & Abbreviations
abbr -a ls 'eza --icons --group-directories-first'
abbr -a ll 'eza -la --icons --group-directories-first --git'
abbr -a tree 'eza --tree --icons'
abbr -a cat 'bat'
# Updated: afetch now points specifically to your small config
abbr -a afetch 'fastfetch -c small.jsonc'
abbr -a grep 'grep --color=auto'

# 3. Zoxide & Starship Initialization
zoxide init fish | source
starship init fish | source

# 4. FZF Initialization
fzf --fish | source

# 5. Global Variable for 'cd' -> 'z' behavior
alias cd='z'

# Keybindings
bind \t accept-autosuggestion
bind \b backward-kill-word # Fixed: standard key for Ctrl+H/Backspace in Fish