#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

dotenv() {
    "$curDir"/env/secrets/dotenv/dotenv_configurer.sh "$@"
}

init() {
    springstarter env secrets dotenv init "$@"
}

prompt() {
    subcommands="$curDir"/env/secrets/.commands

    cat "$subcommands" | nl
    read -p "Your choice: " no

    local choice=$(cat "$subcommands" | nl | head -n"$no" | tail -n1 | cut -f2)
    echo "Selected: $choice"

    "${0}" "$choice"
}

case "${1}" in
init)
    init "${@:2}"
    ;;
dotenv)
    dotenv "${@:2}"
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