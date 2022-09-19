#!/usr/bin/env bash

funcloader="$MYCONFIGLOADER"/.funcloader
envloader="$MYCONFIGLOADER"/.envloader

create_configstore() {
    ([[ -d "$MYCONFIGLOADER" ]] && echo -e "[myfunc config] .configloader already exists") || (mkdir -p "$MYCONFIGLOADER" && echo -e "[myfunc config] .configloader created")
    [[ -L "$funcloader" ]] && echo -e "[myfunc config] .aliasloader already exists" && return 0
    yes | sudo ln -s -i $(dirname $(tracelink myfunc))/myfunc_loader.sh "$funcloader" && echo -e "[myfunc config] .funcloader created"
}

add_funcloader_to_bashrc() {
    [[ $(cat "$envloader" | grep "$funcloader") ]] || echo "[[ -L $funcloader ]] && source $funcloader" >>"$envloader"
    # . ~/.bashrc
}

create_configstore
add_funcloader_to_bashrc

. ~/.bashrc
