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
--list)
    echo "$curDir"/.funcs/* | xargs -n1 | sed "s#.*\.funcs/\(.*\)#\1#"
    ;;
--config)
    echo "$curDir"/.funcs/**/.* | xargs -n1 echo | grep -E "\.function$" | xargs -I X echo "editor X &" | bash
    ;;
--help)
    help
    ;;
*)
    help
    ;;
esac
