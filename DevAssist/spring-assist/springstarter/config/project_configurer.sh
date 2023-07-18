#!/usr/bin/env bash

tmpdir="/tmp/springstarter/project"

# create_local_setup() {
#     mkdir -p "$tmpdir"
#     cp -r "$LINUX_TOOLS_project_config" "$tmpdir"
# }

project_name=

case "${1}" in
init)
    echo -e "init"

    project_name="${@:2}"
    echo -e "project: $project_name"
    [[ ! -d "$(pwd)/$project_name" ]] && echo -e "Not able to find the project directory in the current directory. Exiting." && exit 1
    (
        cd "$(pwd)/$project_name" || exit 1
        # mkdir -p ".setup"
        # cp -r "$tmpdir"/config .setup

        springstarter env secrets dotenv load
        springstarter db init
    )
    ;;
db)
;;
env)
;;
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
