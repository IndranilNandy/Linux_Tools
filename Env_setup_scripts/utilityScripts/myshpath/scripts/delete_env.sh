#!/usr/bin/env bash

remove_env_vars() {
    path="${1}"
    export_expr="${2}"

    envloader="$MYCONFIGLOADER"/.envloader
    sed -i "s@\(.*\):$path\(.*\)@\1\2@" "$envloader"

    [[ ! "$export_expr" ]] && echo -e "no export path provided" && return 0

    export_cmd="export $export_expr"
    sed -i "\,^$export_cmd$,d" "$envloader"
}

remove_env_vars "$@"
