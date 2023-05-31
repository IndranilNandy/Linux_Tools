#!/usr/bin/env bash

curDir="$(pwd)"

update_path() {
    path="${1}"
    envloader="$MYCONFIGLOADER"/.envloader

    # shellcheck source=/dev/null
    . "$HOME"/.bashrc  # Another shell may have updated $PATH in between, so need to refresh

    current_PATH=$(sed -n "/export PATH=/p" "$envloader" | sed "s#export PATH=\(.*\)#\1#")
    expPath="export PATH=$current_PATH"

    (echo "$expPath" | grep -E -v " *#" | grep -q "$path") || expPath="$expPath":"$path"
    if grep -v " *#" "$envloader" | grep -q -E "export PATH"; then
        sed -i "s#\(export PATH=.*\)#$expPath#" "$envloader"
    else
        echo "$expPath" >>"$envloader"
    fi
}

update_export() {
    export_expr="${1}"
    envloader="$MYCONFIGLOADER"/.envloader

    export_cmd="export $export_expr"
    (grep -v " *#" "$envloader" | grep -q -E "$export_cmd") || echo "$export_cmd" >>"$envloader"
}

for arg in "$@"; do
    case "$arg" in
    --path=*)
        path=$(echo "$arg" | sed "s#--path=\(.*\)#\1#")
        update_path "$path"
        ;;
    --export=*)
        exp=$(echo "$arg" | sed "s#--export=\(.*\)#\1#")
        update_export "$exp"
        ;;
    --help)
        cat "$curDir"/myshpath.help
        ;;
    *)
        cat "$curDir"/myshpath.help
        ;;
    esac

done
