#!/usr/bin/env bash

if [[ -z $(which myalias) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which myalias)")")
fi

# curDir="/home/indranil/MyTools/Linux_Tools/Env_setup_scripts/configuration/alias_configurer"

list=$(ls -a "$curDir"/.aliases | grep -E "\..*aliases$" | xargs -I X cat "$curDir"/.aliases/X)

mapfile -t CommandsList <<< "$list"
for item in "${CommandsList[@]}"; do
    echo "alias ${item}"
    alias "${item}"
done

echo -e "aliases loaded"