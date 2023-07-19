#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

prompt() {
    subcommands="$curDir"/config/logging/.commands

    cat "$subcommands" | nl
    read -p "Your choice: " no

    local choice=$(cat "$subcommands" | nl | head -n"$no" | tail -n1 | cut -f2)
    echo "Selected: $choice"

    "${0}" "$choice"
}

init() {
    # _____________________________________________________
    # springstarter config logging log4j2 init "${@}"
    # _____________________________________________________
    "$curDir"/config/logging/log4j2/log4j2_configurer.sh "init" "${@}"
}

case "${1}" in
init)
    echo -e
    echo -e "-----------------------------------"
    echo -e "Logging -- INIT"
    echo -e "-----------------------------------"
    init "${@:2}"
    ;;
log4j2)
    echo -e
    echo -e "-----------------------------------"
    echo -e "Logging -- Log4j2"
    echo -e "-----------------------------------"
    "$curDir"/config/logging/log4j2/log4j2_configurer.sh "${@:2}"
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
