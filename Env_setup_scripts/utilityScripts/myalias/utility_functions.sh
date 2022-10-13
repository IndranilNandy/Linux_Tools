#!/usr/bin/env bash

update_alias_completions_list() {
    gen_alias_compl_loader="$MYCONFIGLOADER"/.generic_alias_completion_loader
    prog_alias_compl_loader="$MYCONFIGLOADER"/.program_alias_completion_loader

    for item in $(ls -a "$curDir"/.aliases | grep -E "\..*aliases$" | grep -v -Fx -f <(cat "$curDir"/.progaliases | grep -v -E " *#" | cut -d':' -f1) | xargs -I X cat "$curDir"/.aliases/X | grep -E -v " *#" | sed "s/\([^=]*\)=.*/\1/"); do
        # [[ $(cat "$gen_alias_compl_loader" | grep -E -v " *#" | cut -f5- -d' '| grep -Fx -- "$item") ]] || echo "complete -F _complete_alias -- $item" >>"$gen_alias_compl_loader"
        [[ $(cat "$gen_alias_compl_loader" | grep -E -v " *#" | awk '{print $NF}' | grep -Fx -- "$item") ]] || echo "complete -F _complete_alias -- $item" >>"$gen_alias_compl_loader"
    done

    while read -r line; do
        pfile="$curDir"/.aliases/$(echo "$line" | cut -f1 -d':')
        com=$(echo "$line" | cut -f2 -d':')

        while read -r item; do
            item=$(echo $item | sed "s/\(.*\)=.*/\1/")

            # [[ $(cat "$prog_alias_compl_loader" | grep -E -v " *#" | grep -E -- " $item$") ]] || echo "$com -- $item" >>"$prog_alias_compl_loader"
            [[ $(cat "$prog_alias_compl_loader" | grep -E -v " *#" | awk '{print $NF}' | grep -Fx -- "$item") ]] || echo "$com -- $item" >>"$prog_alias_compl_loader"
        done < <(cat "$pfile" | grep -E -v "^$" | grep -E -v " *#")

    done < <(cat "$curDir"/.progaliases | grep -E -v "^$" | grep -E -v " *#")
}

update_alias_file() {
    aliasloader="$MYCONFIGLOADER"/.aliasloader
    list=$(ls -a "$curDir"/.aliases | grep -E "\..*aliases$" | xargs -I X cat "$curDir"/.aliases/X | grep -E -v "^$|#.*")

    mapfile -t CommandsList <<<"$list"
    for item in "${CommandsList[@]}"; do
        alias=$(echo "${item}" | sed "s/ *\([^=]*\)=.*/\1/")
        command=$(echo "${item}" | sed "s/[^=]*= *\(.*\)/\1/")
        # echo -e "alias=$alias command=$command"

        alias_command="alias ${alias}='echo -e \"\\\e[33m\\\e[1m${alias}=${command}\\\e[0m\\\n\"; ${command}'"
        grep -q "alias ${alias}=" "$aliasloader" || echo "$alias_command" >>"$aliasloader"
    done
}

reset_completions_list() {
    gen_alias_compl_loader="$MYCONFIGLOADER"/.generic_alias_completion_loader
    prog_alias_compl_loader="$MYCONFIGLOADER"/.program_alias_completion_loader

    >"$gen_alias_compl_loader"
    >"$prog_alias_compl_loader"
    echo -e "reset compl"
}

reset_alias_file() {
    aliasloader="$MYCONFIGLOADER"/.aliasloader
    >"$aliasloader"
    echo -e "reset alias file"
}
