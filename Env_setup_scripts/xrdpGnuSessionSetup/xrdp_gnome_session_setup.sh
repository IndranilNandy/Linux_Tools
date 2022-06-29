#!/bin/bash

file=${1}
[[ ! -e "$file" ]] && echo -e "Failed to change to full Gnome session.\n$file: File doesn't exist. Exiting." && exit 1
[[ ! -e "$file".bak ]] && echo "Creating backup file ${file}.bak" && sudo cp "$file" "$file".bak
(cat ./config/.xrdp-gnome-session-config | xargs -I INPUT ./config/updateXrdpScript.sh INPUT "$file") && echo -e "Successfully changed to full Gnome session.\nReboot needed"
