#!/usr/bin/env bash

. .config

create_configstore() {
    [[ -d "$configloader_src" ]] || mkdir -p "$configloader_src"

    yes | sudo ln -s -i $(pwd)/aliases_loader.sh "$configloader_src"/"$aliasloader"
}

add_aliasloader_to_bashrc() {
    aliasloaderfile="$configloader_src"/"$aliasloader"

    [[ $(cat ~/.bashrc | grep "$aliasloaderfile") ]] || echo ". $aliasloaderfile" >>~/.bashrc
    # . ~/.bashrc
}

update_completealias() {
    echo "TODO"
}

download_completealias() {
    [[ -d "$completealias_src" ]] && return 0
    
    git clone "$completealias_url" "$completealias_src"

    cp "$completealias_src"/complete_alias "$configloader_src"/.complete_alias
    echo ". $configloader_src/.complete_alias" >>~/.bash_completion

    update_completealias
}

create_configstore
add_aliasloader_to_bashrc
download_completealias

yes | sudo ln -s -i $(pwd)/myalias.sh $MYCOMMANDSREPO/myalias
. ~/.bashrc

echo "$aliasloaderfile"
