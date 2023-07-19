#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

secrets() {
    "$curDir"/env/secrets/secrets_configurer.sh "$@"
}

init() {
    echo -e
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${BLUE}${BOLD}[SPRINGSTARTER ENV INIT] Started.${RESET}"
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"

    # _____________________________________________________
    # springstarter env secrets init "${@}"
    # _____________________________________________________
    "$curDir"/env/secrets/secrets_configurer.sh "init" "$@"

    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${BLUE}${BOLD}[SPRINGSTARTER ENV INIT] Finished.${RESET}"
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
}

prompt() {
    subcommands="$curDir"/env/.commands

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
secrets)
    secrets "${@:2}"
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
