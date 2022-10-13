#!/usr/bin/env bash

if [[ -z $(which myalias) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which myalias)")")
fi

. "$curDir"/utility_functions.sh

aliasloader="$MYCONFIGLOADER"/.aliasloader
gen_alias_compl_loader="$MYCONFIGLOADER"/.generic_alias_completion_loader
prog_alias_compl_loader="$MYCONFIGLOADER"/.program_alias_completion_loader

completealias_url="https://github.com/cykerway/complete-alias.git"
completealias_src="$HOME"/.myconfig/complete_alias

envloader="$MYCONFIGLOADER"/.envloader

create_configstore() {
    ([[ -d "$MYCONFIGLOADER" ]] && echo -e "[myalias config] .configloader already exists") || (mkdir -p "$MYCONFIGLOADER" && echo -e "[myalias config] .configloader created")

    [[ -e "$gen_alias_compl_loader" ]] || touch "$gen_alias_compl_loader"
    [[ -e "$prog_alias_compl_loader" ]] || touch "$prog_alias_compl_loader"

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
    [[ -e "$MYCONFIGLOADER"/.complete_alias ]] || cp "$completealias_src"/complete_alias "$MYCONFIGLOADER"/.complete_alias

    [[ $(cat "$HOME"/.bash_completion | grep "source $MYCONFIGLOADER/.complete_alias") ]] || echo "[[ -f $MYCONFIGLOADER/.complete_alias ]] && source $MYCONFIGLOADER/.complete_alias" >>~/.bash_completion

    [[ $(cat "$MYCONFIGLOADER/.complete_alias" | grep "$gen_alias_compl_loader") ]] || echo "[[ -e $gen_alias_compl_loader ]] && source $gen_alias_compl_loader" >>"$MYCONFIGLOADER/.complete_alias"
    [[ $(cat "$MYCONFIGLOADER/.complete_alias" | grep "$prog_alias_compl_loader") ]] || echo "[[ -e $prog_alias_compl_loader ]] && source $prog_alias_compl_loader" >>"$MYCONFIGLOADER/.complete_alias"

    #     pattern="complete -F _complete_alias \"\\$\{\!BASH_ALIASES\[@\]\}\""
    #     [[ $(cat "$MYCONFIGLOADER/.complete_alias" | grep -E -v " *#" | grep -E "$pattern") ]] && echo -e "[myalias config] .complete_alias already updated." && return 0
    #     [[ $(cat "$MYCONFIGLOADER/.complete_alias" | grep -E -v " *#" | grep "myalias") ]] && echo -e "[myalias config] .complete_alias already updated." && return 0

    #     # If you wan't to add all aliases then only the last statement is enough
    # #     cat <<EOF >>"$MYCONFIGLOADER/.complete_alias"
    # # for item in \$(myalias --set); do
    # # complete -F _complete_alias "\$item" 2> /dev/null
    # # done

    # # complete -F _complete_alias "\${!BASH_ALIASES[@]}"
    # # EOF

    #     cat <<EOF >>"$MYCONFIGLOADER/.complete_alias"
    # complete -F _complete_alias "\${!BASH_ALIASES[@]}"
    # EOF
}

create_configstore
add_aliasloader_to_bashrc
download_completealias
update_completealias
update_alias_completions_list

. ~/.bashrc
