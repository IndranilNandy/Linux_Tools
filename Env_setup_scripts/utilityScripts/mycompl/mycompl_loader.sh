#!/usr/bin/env bash

if [[ -z $(which mycompl) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which mycompl)")")
fi

list=$(ls -a "$curDir"/.completions | grep -E "\..*completions$" | xargs -I X cat "$curDir"/.completions/X | grep -E -v "^$|#.*")

mapfile -t CommandsList <<<"$list"
for item in "${CommandsList[@]}"; do
    # echo "${item}"
    eval "complete ${item}"
done
