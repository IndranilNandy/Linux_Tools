#!/usr/bin/env bash


if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/../../../.systemConfig
. "$curDir"/../../../vars/.colors

default_choice="project"

case "${1}" in
init)
    springstarter project init "${@:2}"
    ;;
project)
    "$curDir"/project/project_setup.sh "${@:2}"
    ;;
config)
    "$curDir"/config/project_configurer.sh "${@:2}"
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
