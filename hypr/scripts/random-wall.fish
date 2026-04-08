#!/usr/bin/fish

# 1. Load your fish functions so the script can "see" the theme function
source ~/.config/fish/functions/theme.fish

# 2. Set your wallpaper directory
set wall_dir ~/wallpapers

# 3. Pick a random image
set random_wall (ls $wall_dir | shuf -n 1)

# 4. Run the full theme sequence
theme $wall_dir/$random_wall
