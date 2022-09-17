#!/usr/bin/env bash

if [[ -z $(which myalias) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which myalias)")")
fi

list=$(ls -a "$curDir"/.aliases | grep -E "\..*aliases$" | xargs -I X cat "$curDir"/.aliases/X | grep -E -v "^$|#.*")

mapfile -t CommandsList <<<"$list"
for item in "${CommandsList[@]}"; do
    # echo "alias ${item}"
    alias "${item}"
done

# echo -e "aliases loaded"
