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
    db_choice="${1}"
    case "$db_choice" in
    postgresql)
        springstarter db postgresql init
        ;;
    mysql)
        echo -e "mysql"
        ;;
    *)
        echo -e "Invalid option ${1}"
        ;;
    esac
}

case "${1}" in
init)
    init "${@:2}"
    ;;
postgresql)
    pgsql "${@:2}"
    ;;
*)
    echo "--help"
    ;;
esac
