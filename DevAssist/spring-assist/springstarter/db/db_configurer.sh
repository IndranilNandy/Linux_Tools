#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

pgsql() {
    "$curDir"/db/pgsql/pgsql_configurer.sh "$@"
}

init() {
    springstarter db postgresql init "${@}"
}

prompt() {
    subcommands="$curDir"/db/.commands

    cat "$subcommands" | nl
    read -p "Your choice: " no

    local choice=$(cat "$subcommands" | nl | head -n"$no" | tail -n1 | cut -f2)
    echo "Selected: $choice"

    "${0}" "$choice"
}

case "${1}" in
init)
    init "${@:2}"
    ;;
postgresql)
    pgsql "${@:2}"
    ;;
mysql)
    echo -e "mysql config yet to be implemented"
    ;;
help)
    echo --help
    ;;
'')
    prompt
    ;;
*)
    echo "--help"
    ;;
esac
