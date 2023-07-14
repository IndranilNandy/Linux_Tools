#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

container() {
    echo "from container -> ""$*"
    "$curDir"/db/pgsql/container/pgsql_container_configurer.sh "${@:2}"
}

case "${1}" in
container)
    container "$@"
    ;;
*)
    echo "--help"
    ;;
esac
