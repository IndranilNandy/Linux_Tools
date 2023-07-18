#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/../../../.systemConfig
. "$curDir"/../../../vars/.colors

prompt() {
    subcommands="$curDir"/.commands

    cat "$subcommands" | nl
    read -p "Your choice: " no

    local choice=$(cat "$subcommands" | nl | head -n"$no" | tail -n1 | cut -f2)
    echo "Selected: $choice"

    "${0}" "$choice"
}

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
help)
    echo --help
    ;;
'')
    prompt
    ;;
*)
    echo "--help"
    ;;
esac
