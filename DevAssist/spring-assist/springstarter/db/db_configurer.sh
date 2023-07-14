#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

pgsql() {
    echo "from pgsql -> ""$*"
    "$curDir"/db/pgsql/pgsql_configurer.sh "${@:2}"
}

case "${1}" in
postgresql)
    pgsql "$@"
    ;;
*)
    echo "--help"
    ;;
esac
