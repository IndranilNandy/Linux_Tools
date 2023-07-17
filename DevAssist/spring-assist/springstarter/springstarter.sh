#!/usr/bin/env bash


if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/../../../.systemConfig
. "$curDir"/../../../vars/.colors

case "${1}" in
project)
    "$curDir"/project/project_setup.sh "${@:2}"
    ;;
db)
    "$curDir"/db/db_configurer.sh "${@:2}"
    ;;
env)
    "$curDir"/env/env_configurer.sh "${@:2}"
    ;;
*)
    echo "--help"
    ;;
esac
