#!/usr/bin/env bash

load_alias_completions() {
    gen_alias_compl_loader="$MYCONFIGLOADER"/.generic_alias_completion_loader
    prog_alias_compl_loader="$MYCONFIGLOADER"/.program_alias_completion_loader

    if [[ "${1}" == "1" ]]; then
        >"$gen_alias_compl_loader"
        >"$prog_alias_compl_loader"
    fi

    for item in $(ls -a "$curDir"/.aliases | grep -E "\..*aliases$" | grep -v -Fx -f <(cat "$curDir"/.progaliases | grep -v -E " *#" | cut -d':' -f1) | xargs -I X cat "$curDir"/.aliases/X | grep -E -v " *#" | sed "s/\(.*\)=.*/\1/"); do
        [[ $(cat "$gen_alias_compl_loader" | grep -E -v " *#" | grep -F -- "$item") ]] || echo "complete -F _complete_alias -- $item" >>"$gen_alias_compl_loader"
    done

    while read -r line; do
        pfile="$curDir"/.aliases/$(echo "$line" | cut -f1 -d':')
        com=$(echo "$line" | cut -f2 -d':')

        while read -r item; do
            item=$(echo $item | sed "s/\(.*\)=.*/\1/")

            [[ $(cat "$prog_alias_compl_loader" | grep -E -v " *#" | grep -E -- " $item$") ]] || echo "$com -- $item" >>"$prog_alias_compl_loader"
        done < <(cat "$pfile" | grep -E -v "^$" | grep -E -v " *#")

    done < <(cat "$curDir"/.progaliases | grep -E -v "^$" | grep -E -v " *#")
}
