#!/usr/bin/env bash

if [[ -z $(which myfunc) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which myfunc)")")
fi

for funcdef in $(echo "$curDir"/.funcs/**/.* | xargs -n1 echo | grep -E "\.function$"); do
    source "$funcdef"
done
# source "$curDir"/.funcs/generic/.function
# source "$curDir"/.funcs/myhistory/.function
# source "$curDir"/.funcs/qcd/.function
