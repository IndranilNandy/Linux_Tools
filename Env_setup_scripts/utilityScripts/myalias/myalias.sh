#!/usr/bin/env bash

if [[ -z $(which myalias) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which myalias)")")
fi

. "$curDir"/utility_functions.sh

aliasfiles() {
    ls -a "$curDir"/.aliases | grep -E "\..*aliases$" | xargs -I X cat "$curDir"/.aliases/X
}

help() {
    cat "$curDir"/help/myalias.help
}

case ${1} in
--list*)
    param=$(echo ${1} | sed "s/--list\(.*\)/\1/")

    if [[ -z "$param" ]]; then
        aliasfiles
    else
        aliasfiles | grep "$param"
    fi
    ;;
--set)
    aliasfiles | grep -E -v " *#" | sed "s/\(.*\)=.*/\1/"
    ;;
--config)
    ls -a "$curDir"/.aliases | grep -E "\..*aliases$" | xargs -I X echo "editor $curDir/.aliases/X &" | bash
    echo -e "Run 'myalias --refresh' to affect alias-update on completions list"
    ;;
--prune)
    case ${2} in
    --compl)
        reset_completions_list
        update_alias_completions_list
        ;;
    --alias)
        reset_alias_file
        update_alias_file
        ;;
    '')
        echo "reset everything"
        reset_alias_file
        reset_completions_list
        update_alias_file
        update_alias_completions_list
        ;;
    *)
        echo -e "check command with myalias --help"
    esac
    ;;
--refresh)
    update_alias_file
    update_alias_completions_list
    ;;
--help)
    help
    ;;
'')
    help
    ;;
*)
    if [[ -z $(echo "$*" | grep -E =) ]]; then
        help && exit 0
    fi
    cat "$curDir"/.aliases/.genericaliases | grep "$*" || echo $* >>"$curDir"/.aliases/.genericaliases && echo -e "Before using this alias, open a new window"
    update_alias_file
    update_alias_completions_list
    ;;
esac
