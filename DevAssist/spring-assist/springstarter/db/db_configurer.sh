#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

pgsql() {
    "$curDir"/db/pgsql/pgsql_configurer.sh "$@"
}

case "${1}" in
postgresql)
    pgsql "${@:2}"
    ;;
*)
    echo "--help"
    ;;
esac
