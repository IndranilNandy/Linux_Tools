#!/usr/bin/env bash

if [[ -z $(which mycompl) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which mycompl)")")
fi

help() {
    cat "$curDir"/help/mycompl.help
}

addCompletions() {
    local scriptName="${1}"
    local compl_entry="${@:2}"

    [[ $(cat "$curDir"/.completions/"$scriptName" | grep -v "^#" | grep -- "$compl_entry") ]] && return 1

    p=$(echo "$compl_entry" | awk '{ print $NF }')
    # Prune outdated existing entry
    [[ $(cat "$curDir"/.completions/"$scriptName" | grep -v "^#" | grep -- " $p$") ]] && sed -i "/ $p$/d" "$curDir"/.completions/"$scriptName"

    echo "$compl_entry" >>"$curDir"/.completions/"$scriptName"
    return 0
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
--temp)
    addCompletions ".tempcompletions" "${@:2}" || exit 0
    ;;
--dynamic)
    addCompletions ".dynamiccompletions" "${@:2}" || exit 0
    ;;
*)
    addCompletions ".scriptgeneratedcompletions" "$@" || exit 0
    ;;
esac
