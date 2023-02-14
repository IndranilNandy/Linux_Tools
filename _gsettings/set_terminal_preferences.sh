#!/usr/bin/env bash

GNOME_TERMINAL_PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | awk -F \' '{print $2}')
profile_file="./terminal_preferences/myCustomProfile3.txt"
g_cmd="gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"
cat "$profile_file" | grep -v "^#" | grep -v "^$" | gawk -v prf="$GNOME_TERMINAL_PROFILE" -v gcmd="$g_cmd" 'BEGIN { FS = ":" }; { print gcmd prf"/ "$1 $2}' | bash
