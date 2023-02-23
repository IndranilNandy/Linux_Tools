#!/usr/bin/env bash

add_env_var() {
    path="${1}"
    export_expr="${2}"

    envloader="$MYCONFIGLOADER"/.envloader

    expPath="export PATH=$PATH"
    (echo "$expPath" | grep -E -v " *#" | grep -q "$path") || expPath="$expPath":"$path"
    if grep -v " *#" "$envloader" | grep -q -E "export PATH" ; then
        sed -i "s#\(export PATH=.*\)#$expPath#" "$envloader"
    else
        echo "$expPath" >>"$envloader"
    fi

    [[ ! "$export_expr" ]] && echo -e "no export path provided" && return 0

    export_cmd="export $export_expr"
    (grep -v " *#" "$envloader" | grep -q -E "$export_cmd") || echo "$export_cmd" >>"$envloader"
}

add_env_var "$@"
