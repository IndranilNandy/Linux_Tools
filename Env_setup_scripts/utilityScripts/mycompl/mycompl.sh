#!/usr/bin/env bash

if [[ -z $(which mycompl) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which mycompl)")")
fi

help() {
    cat "$curDir"/help/mycompl.help
}

case ${1} in
--config)
    ls -a "$curDir"/.completions | grep -E "\..*completions$" | xargs -I X echo "editor $curDir/.completions/X &" | bash
    ;;
--help)
    help
    ;;
'')
    help
    ;;
*)
    [[ $(cat "$curDir"/.completions/.genericcompletions | grep -v "^#" | grep -- "$*" ) ]] || echo "$*" >> "$curDir"/.completions/.genericcompletions
    ;;
esac