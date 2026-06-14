#!/bin/bash
search_paths=("$HOME" "/mnt/windows/Users" "/mnt/windows/Repositories" "/mnt/windows/Video" "/mnt/windows/Masum Ali")
target=$(find "${search_paths[@]}" -maxdepth 4 -not -path '*/.*' -not -path '*/Windows/*' -not -path '*/Program Files*' -not -path '*/$Recycle.Bin/*' 2>/dev/null | fuzzel -d -p "Finder: " --width 60)
if [ -n "$target" ]; then
    xdg-open "$target"
fi
