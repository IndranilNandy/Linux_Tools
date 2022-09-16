#!/usr/bin/env bash

. .config

create_configstore() {
    ([[ -d "$configloader_src" ]] && echo -e "[myalias] .configloader already exists") || (mkdir -p "$configloader_src" && echo -e "[myalias] .configloader created")
    [[ -L "$configloader_src"/"$aliasloader" ]] && echo -e "[myalias] .aliasloader already exists" && return 0
    yes | sudo ln -s -i $(pwd)/aliases_loader.sh "$configloader_src"/"$aliasloader" && echo -e "[myalias] .aliasloader created"
}

add_aliasloader_to_bashrc() {
    aliasloaderfile="$configloader_src"/"$aliasloader"

    [[ $(cat "$envloader" | grep "$aliasloaderfile") ]] || echo "[[ -L $aliasloaderfile ]] && source $aliasloaderfile" >>"$envloader"
    # . ~/.bashrc
}

update_completealias() {
    [[ -e "$configloader_src"/.complete_alias ]] || cp "$completealias_src"/complete_alias "$configloader_src"/.complete_alias
    [[ $(cat "$HOME"/.bash_completion | grep "source $configloader_src/.complete_alias") ]] || echo "[[ -f $configloader_src/.complete_alias ]] && source $configloader_src/.complete_alias" >>~/.bash_completion

    [[ $(cat "$configloader_src/.complete_alias" | grep "myalias.sh") ]] && echo -e "[myalias] .complete_alias already updated." && return 0

    # If you wan't to add all aliases then only the last statement is enough
#     cat <<EOF >>"$configloader_src/.complete_alias"
# for item in \$(\$HOME/MyTools/Linux_Tools/Env_setup_scripts/configuration/alias_configurer/myalias.sh --set); do
# complete -F _complete_alias "\$item" 2> /dev/null
# done

# complete -F _complete_alias "\${!BASH_ALIASES[@]}"
# EOF

    cat <<EOF >>"$configloader_src/.complete_alias"
complete -F _complete_alias "\${!BASH_ALIASES[@]}"
EOF
}

download_completealias() {
    [[ -d "$completealias_src" ]] && echo -e "[myalias] completealias repo already downloaded" && return 0

    git clone "$completealias_url" "$completealias_src"

}

create_configstore
add_aliasloader_to_bashrc
download_completealias
update_completealias

. ~/.bashrc

[[ -L "$MYCOMMANDSREPO/myalias" ]] && echo -e "[myalias] myalias already exists" && exit 0
yes | sudo ln -s -i $(pwd)/myalias.sh $MYCOMMANDSREPO/myalias
