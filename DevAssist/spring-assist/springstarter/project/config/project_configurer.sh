#!/usr/bin/env bash

tmpdir="/tmp/springstarter/project"

create_local_setup() {
    mkdir -p "$tmpdir"
    cp -r "$LINUX_TOOLS_project_config" "$tmpdir"
}
case "${1}" in
appyaml)
    # "$curDir"/project/config/project_configurer.sh "${@:2}"
    ;;
buildgradle)
    # "$curDir"/db/db_configurer.sh "${@:2}"
    ;;
metadata)
    # "$curDir"/env/env_configurer.sh "${@:2}"
    ;;
'')
    echo empty
    # create_local_setup
    ;;
*)
    echo "--help"
    ;;
esac