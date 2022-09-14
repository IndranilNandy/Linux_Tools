#!/usr/bin/env bash

if [[ -z $(which myalias) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which myalias)")")
fi
# curDir="/home/indranil/MyTools/Linux_Tools/Env_setup_scripts/configuration/alias_configurer"

# cat "$curDir"/.aliases/.genericaliases | grep "$*" || echo $* >>"$curDir"/.aliases/.genericaliases && echo -e "Before using this alias, open a new window"

case ${1} in
--list)
    echo "list"
    ls -a "$curDir"/.aliases | grep -E "\..*aliases$" | xargs -I X cat "$curDir"/.aliases/X
    ;;
--set)
    echo "set"
    ls -a "$curDir"/.aliases | grep -E "\..*aliases$" | xargs -I X cat "$curDir"/.aliases/X | sed "s/\(.*\)=.*/\1/"
    ;;
*)
    cat "$curDir"/.aliases/.genericaliases | grep "$*" || echo $* >>"$curDir"/.aliases/.genericaliases && echo -e "Before using this alias, open a new window"
    ;;
esac
