#!/usr/bin/env bash

complloader="$MYCONFIGLOADER"/.completionloader
envloader="$MYCONFIGLOADER"/.envloader

create_configstore() {
    ([[ -d "$MYCONFIGLOADER" ]] && echo -e "[mycompl] .configloader already exists") || (mkdir -p "$MYCONFIGLOADER" && echo -e "[mycompl] .configloader created")
    [[ -L "$complloader" ]] && echo -e "[mycompl] .completionloader already exists" && return 0
    yes | sudo ln -s -i $(dirname $(tracelink mycompl))/mycompl_loader.sh "$complloader" && echo -e "[mycompl config] .completionloader created"
}

add_complloader_to_bashrc() {
    [[ $(cat "$envloader" | grep -v "^#" | grep "$complloader") ]] || echo "[[ -e $complloader ]] && source $complloader" >>"$envloader"
}

create_configstore
add_complloader_to_bashrc