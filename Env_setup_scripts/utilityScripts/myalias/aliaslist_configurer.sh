#!/usr/bin/env bash

. .config

create_configstore() {
    ([[ -d "$configloader_src" ]] && echo -e "[myalias config] .configloader already exists") || (mkdir -p "$configloader_src" && echo -e "[myalias config] .configloader created")
    [[ -L "$aliasloader" ]] && echo -e "[myalias config] .aliasloader already exists" && return 0
    yes | sudo ln -s -i $(dirname $(tracelink myalias))/aliases_loader.sh "$aliasloader" && echo -e "[myalias config] .aliasloader created"
}

add_aliasloader_to_bashrc() {
    [[ $(cat "$envloader" | grep "$aliasloader") ]] || echo "[[ -L $aliasloader ]] && source $aliasloader" >>"$envloader"
    # . ~/.bashrc
}

download_completealias() {
    [[ -d "$completealias_src" ]] && echo -e "[myalias config] completealias repo already downloaded" && return 0

    git clone "$completealias_url" "$completealias_src"
}

update_completealias() {
    [[ -e "$configloader_src"/.complete_alias ]] || cp "$completealias_src"/complete_alias "$configloader_src"/.complete_alias

    [[ $(cat "$HOME"/.bash_completion | grep "source $configloader_src/.complete_alias") ]] || echo "[[ -f $configloader_src/.complete_alias ]] && source $configloader_src/.complete_alias" >>~/.bash_completion

    pattern="complete -F _complete_alias \"\\$\{\!BASH_ALIASES\[@\]\}\""
    [[ $(cat "$configloader_src/.complete_alias" | grep -E -v " *#" | grep -E "$pattern") ]] && echo -e "[myalias config] .complete_alias already updated." && return 0
    [[ $(cat "$configloader_src/.complete_alias" | grep -E -v " *#" | grep "myalias") ]] && echo -e "[myalias config] .complete_alias already updated." && return 0

    # If you wan't to add all aliases then only the last statement is enough
#     cat <<EOF >>"$configloader_src/.complete_alias"
# for item in \$(myalias --set); do
# complete -F _complete_alias "\$item" 2> /dev/null
# done

# complete -F _complete_alias "\${!BASH_ALIASES[@]}"
# EOF

    cat <<EOF >>"$configloader_src/.complete_alias"
complete -F _complete_alias "\${!BASH_ALIASES[@]}"
EOF
}

create_configstore
add_aliasloader_to_bashrc
download_completealias
update_completealias

. ~/.bashrc
