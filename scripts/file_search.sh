#!/usr/bin/env bash

# User-focused search directories
search_paths=("$HOME" "/mnt/windows/Repositories" "/mnt/windows/Video" "/mnt/windows/Masum Ali")

# Only query directories that currently exist and are mounted
valid_paths=()
for p in "${search_paths[@]}"; do
    [ -d "$p" ] && valid_paths+=("$p")
done

# Search command: prefers fast multi-threaded 'fd', falls back to standard 'find'
if command -v fd &>/dev/null; then
    target=$(fd --max-depth 4 \
        --exclude "node_modules" \
        --exclude ".git" \
        --exclude ".cache" \
        --exclude "build" \
        --exclude "target" \
        --exclude ".gradle" \
        --exclude "Windows" \
        --exclude "Program Files*" \
        --exclude "$Recycle.Bin" \
        . "${valid_paths[@]}" 2>/dev/null | fuzzel -d -p "Finder: " --width 60 --lines 12 --font="Geist:weight=bold:size=10")
else
    target=$(find "${valid_paths[@]}" -maxdepth 4 \
        -not -path '*/.*' \
        -not -path '*/node_modules/*' \
        -not -path '*/build/*' \
        -not -path '*/target/*' \
        -not -path '*/.gradle/*' \
        -not -path '*/Windows/*' \
        -not -path '*/Program Files*' \
        -not -path '*/$Recycle.Bin/*' 2>/dev/null | fuzzel -d -p "Finder: " --width 60 --lines 12 --font="Geist:weight=bold:size=10")
fi

if [ -n "$target" ]; then
    xdg-open "$target"
fi
