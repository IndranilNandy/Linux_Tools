#!/usr/bin/env bash


if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/../../../.systemConfig
. "$curDir"/../../../vars/.colors

case "${1}" in
db)
    "$curDir"/db/db_configurer.sh "${@:2}"
    ;;
*)
    echo "--help"
    ;;
esac
