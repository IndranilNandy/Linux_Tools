#!/usr/bin/env bash

curDir="$(pwd)"

remove_path() {
    path="${1}"
    envloader="$MYCONFIGLOADER"/.envloader
    sed -i "s@\(.*\):$path\(.*\)@\1\2@" "$envloader"
}

remove_export() {
    export_expr="${1}"
    envloader="$MYCONFIGLOADER"/.envloader

    export_cmd="export $export_expr"
    sed -i "\,^$export_cmd$,d" "$envloader"
}

for arg in "$@"; do
    case "$arg" in
    --path=*)
        path=$(echo "$arg" | sed "s#--path=\(.*\)#\1#")
        remove_path "$path"
        ;;
    --export=*)
        exp=$(echo "$arg" | sed "s#--export=\(.*\)#\1#")
        remove_export "$exp"
        ;;
    --help)
        cat "$curDir"/myshpath.help
        ;;
    *)
        cat "$curDir"/myshpath.help
        ;;
    esac

done
