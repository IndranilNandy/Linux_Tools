#!/usr/bin/env bash

. .config

create_refstore() {
    [[ -d "$refloader" ]] && echo -e "[refloader] Already exists" && return 0
    mkdir -p "$refloader" && echo -e "[refloader] .refloader created"
}

create_symlinks() {
    ls -a1 "$refloader" | grep -E -v "\.$|\.\.$" | xargs -I X echo "yes | sudo ln -s -i $refloader/X $scriptRefsRoot/X" | bash
}

create_refstore
create_symlinks
