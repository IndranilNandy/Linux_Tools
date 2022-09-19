#!/usr/bin/env bash

if [[ -z $(which myfunc) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which myfunc)")")
fi

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
    aliasfiles | sed "s/\(.*\)=.*/\1/"
    ;;
--config)
    ls -a "$curDir"/.aliases | grep -E "\..*aliases$" | xargs -I X echo "editor $curDir/.aliases/X &" | bash
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
    ;;
esac
