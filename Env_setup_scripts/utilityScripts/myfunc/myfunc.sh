#!/usr/bin/env bash

if [[ -z $(which myfunc) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which myfunc)")")
fi

help() {
    cat "$curDir"/help/myfunc.help
}

case ${1} in
--config)
    # ls -a "$curDir"/.aliases | grep -E "\..*aliases$" | xargs -I X echo "editor $curDir/.aliases/X &" | bash
    echo "$curDir"/.funcs/**/.* | xargs -n1 echo | grep -E "\.function$" | xargs -I X echo "editor $curDir/.aliases/X &" | bash
    ;;
--help)
    help
    ;;
*)
    help
    ;;
esac
