#!/bin/bash

replacement=${1}
file=${2}

(sudo grep "$replacement" "$file" >/dev/null) && echo "[EXISTS] $replacement. Doing nothing." && exit 0

sudo sed -i -e "1 s/^$/$replacement/;t" -e "1,// s//$replacement\n/" "$file"
