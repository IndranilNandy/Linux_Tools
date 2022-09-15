#!/usr/bin/env bash

. .config

create_configstore() {
    [[ -d "$configloader_src" ]] || mkdir -p "$configloader_src"

    yes | sudo ln -s -i $(pwd)/aliases_loader.sh "$configloader_src"/"$aliasloader"
}

add_aliasloader_to_bashrc() {
    aliasloaderfile="$configloader_src"/"$aliasloader"

    [[ $(cat "$envloader" | grep "$aliasloaderfile") ]] || echo "source $aliasloaderfile" >>"$envloader"
    . ~/.bashrc
}

update_completealias() {
    cp "$completealias_src"/complete_alias "$configloader_src"/.complete_alias
    [[ $(cat "$HOME"/.bash_completion | grep "source $configloader_src/.complete_alias") ]] || echo "source $configloader_src/.complete_alias" >>~/.bash_completion

    [[ $(cat "$configloader_src/.complete_alias" | grep "myalias.sh") ]] && echo -e ".complete_alias already updated." && return 0

    cat <<EOF >>"$configloader_src/.complete_alias"
for item in \$(/home/indranil/MyTools/Linux_Tools/Env_setup_scripts/configuration/alias_configurer/myalias.sh --set); do
complete -F _complete_alias "\$item"
done

complete -F _complete_alias "\${!BASH_ALIASES[@]}"
EOF
}

download_completealias() {
    [[ -d "$completealias_src" ]] && return 0

    git clone "$completealias_url" "$completealias_src"

}

create_configstore
add_aliasloader_to_bashrc
download_completealias
update_completealias

yes | sudo ln -s -i $(pwd)/myalias.sh $MYCOMMANDSREPO/myalias
. ~/.bashrc

echo "$aliasloaderfile"
