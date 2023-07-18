#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

container() {
    "$curDir"/db/pgsql/container/pgsql_container_configurer.sh "${@}"
}

init() {
    springstarter db postgresql container init "${@}"
}

prompt() {
    choice="${1}"
    case "$choice" in
    container)
        springstarter db postgresql container init
        ;;
    # mysql)
    #     echo -e "mysql"
    #     ;;
    *)
        echo -e "Invalid option ${1}"
        ;;
    esac

}

case "${1}" in
init)
    init "${@:2}"
    ;;
container)
    container "${@:2}"
    ;;
*)
    echo "--help"
    ;;
esac
