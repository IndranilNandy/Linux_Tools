#!/bin/bash

updateXrdpScript() {
    local replacement=${1}
    local file=${2}

    sudo grep "$replacement" "$file" >/dev/null && echo "[EXISTS] $replacement: Doing nothing." && return

    sudo sed -i -e "1 s/^$/$replacement/;t" -e "1,// s//$replacement\n/" "$file"
}

export -f updateXrdpScript

file=${1}

[[ ! -e "$file" ]] && echo -e "Failed to change to full Gnome session.\n$file: File doesn't exist. Exiting." && exit 1
[[ ! -e "$file".bak ]] && echo "Creating backup file ${file}.bak" && sudo cp "$file" "$file".bak
cat ./config/.xrdp-gnome-session-config | xargs -I INPUT bash -c "updateXrdpScript 'INPUT' $file" && echo -e "Successfully changed to full Gnome session.\nReboot needed"
