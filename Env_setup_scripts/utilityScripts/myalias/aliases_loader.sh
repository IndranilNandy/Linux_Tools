#!/usr/bin/env bash

if [[ -z $(which myalias) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which myalias)")")
fi

list=$(ls -a "$curDir"/.aliases | grep -E "\..*aliases$" | xargs -I X cat "$curDir"/.aliases/X | grep -E -v "^$|#.*")

mapfile -t CommandsList <<<"$list"
for item in "${CommandsList[@]}"; do
    alias=$(echo "${item}" | sed "s/ *\([^=]*\)=.*/\1/")
    command=$(echo "${item}" | sed "s/[^=]*= *\(.*\)/\1/")
    # echo -e "alias=$alias command=$command"
    
    if [[ -z $(which ${alias}) ]]; then
        alias "${alias}=echo ${alias}=${command}; ${command}"
    else
        echo -e "[ERROR] Cannot set alias ${item}. $(which ${alias}) already exists"
    fi
done
