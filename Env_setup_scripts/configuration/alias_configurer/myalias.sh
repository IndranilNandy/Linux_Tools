#!/usr/bin/env bash

if [[ -z $(which myalias) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which myalias)")")
fi

aliasfiles() {
    ls -a "$curDir"/.aliases | grep -E "\..*aliases$" | xargs -I X cat "$curDir"/.aliases/X
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
    cat "$curDir"/help/myalias.help
    ;;
'')
    cat "$curDir"/help/myalias.help
    ;;
*)
    cat "$curDir"/.aliases/.genericaliases | grep "$*" || echo $* >>"$curDir"/.aliases/.genericaliases && echo -e "Before using this alias, open a new window"
    ;;
esac
