#!/usr/bin/env bash

if [[ -z $(which myalias) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which myalias)")")
fi

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

update_alias_compl_loader() {
    for item in $(ls -a "$curDir"/.aliases | grep -E "\..*aliases$" | grep -v -Fx -f <(cat "$curDir"/.progaliases | grep -v -E " *#" | cut -d':' -f1) | xargs -I X cat "$curDir"/.aliases/X | grep -E -v " *#" | sed "s/\(.*\)=.*/\1/"); do
        [[ $(cat "$gen_alias_compl_loader" | grep -E -v " *#" | grep -E -- "$item") ]] || echo "complete -F _complete_alias -- $item" >>"$gen_alias_compl_loader"
    done

    # for item in $(ls -a "$curDir"/.aliases | grep -E "\..*aliases$" | grep -f "$curDir"/.progaliases | xargs -I X cat "$curDir"/.aliases/X | grep -E -v " *#" | sed "s/\(.*\)=.*/\1/"); do
    #     [[ $(cat "$prog_alias_compl_loader" | grep -E -v " *#" | grep -E -- "$item") ]] || echo "complete -F _complete_alias -- $item" >> "$prog_alias_compl_loader"
    # done

    # for line in $(cat "$curDir"/.progaliases | xargs -I X echo X); do
    #     echo line="$line"
    #     pfile="$curDir"/.aliases/$(echo "$line" | cut -f1 -d':')
    #     com=$(echo "$line" | cut -f2 -d':')
    #     cat "$pfile"

    #     for item in $(cat $pfile); do
    #         [[ $(cat "$prog_alias_compl_loader" | grep -E -v " *#" | grep -E -- "$item") ]] || echo "$com -- $item" >>"$prog_alias_compl_loader"
    #     done

    #     complete | grep -E " $aliasfile$"
    # done

    while read -r line; do
        # echo -e "$line\n"
        pfile="$curDir"/.aliases/$(echo "$line" | cut -f1 -d':')
        com=$(echo "$line" | cut -f2 -d':')
        # cat "$pfile"

        # for item in $(cat $pfile); do
        #     [[ $(cat "$prog_alias_compl_loader" | grep -E -v " *#" | grep -E -- "$item") ]] || echo "$com -- $item" >>"$prog_alias_compl_loader"
        # done
        while read -r item; do
            [[ -n $(echo "$item" | grep -E -v "^$" | grep -E -v " *#") ]] && [[ -z $(cat "$prog_alias_compl_loader" | grep -E -v " *#" | grep -E -- "$item") ]] && echo "$com -- $(echo $item | sed "s/\(.*\)=.*/\1/")" >>"$prog_alias_compl_loader"
        done <"$pfile"

        # complete | grep -E " $aliasfile$"
    done < <(cat "$curDir"/.progaliases | grep -E -v " *#")

}

create_configstore
add_aliasloader_to_bashrc
download_completealias
update_completealias
update_alias_compl_loader

. ~/.bashrc
