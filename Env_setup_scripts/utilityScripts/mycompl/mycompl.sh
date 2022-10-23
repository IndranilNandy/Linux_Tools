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
    ls -a "$curDir"/.completions | grep -E "\..*completions$" | xargs -I X echo "echo \"echo Opening $curDir/.completions/X && editor -w $curDir/.completions/X\" | bash" | bash
    ;;
--help)
    help
    ;;
'')
    help
    ;;
*)
    [[ $(cat "$curDir"/.completions/.genericcompletions | grep -v "^#" | grep -- "$*" ) ]] && exit 0

    p=$(echo "$*" | awk '{ print $NF }')
    # Prune outdated existing entry
    [[ $(cat "$curDir"/.completions/.genericcompletions | grep -v "^#" | grep -- " $p$" ) ]] && sed -i "/ $p$/d" "$curDir"/.completions/.genericcompletions
    
    echo "$*" >> "$curDir"/.completions/.genericcompletions
    ;;
esac