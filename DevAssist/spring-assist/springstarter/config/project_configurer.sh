#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

tmpdir="/tmp/springstarter/project"

# create_local_setup() {
#     mkdir -p "$tmpdir"
#     cp -r "$LINUX_TOOLS_project_config" "$tmpdir"
# }

db() {
    # _____________________________________________________
    # springstarter db "${@}"
    # _____________________________________________________
    "$curDir"/db/db_configurer.sh "$@"
}

env() {
    # _____________________________________________________
    # springstarter env "${@}"
    # _____________________________________________________
    "$curDir"/env/env_configurer.sh "${@}"
}

init() {
    echo -e
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${BLUE}${BOLD}[SPRINGSTARTER CONFIG INIT] Started.${RESET}"
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"

    # _____________________________________________________
    # springstarter env init "${@}"
    # _____________________________________________________
    "$curDir"/env/env_configurer.sh "init" "$@"

    # _____________________________________________________
    # springstarter config appyaml init "${@}"
    # _____________________________________________________
    "$curDir"/config/appyaml/appyaml_configurer.sh "init" "${@}"

    # _____________________________________________________
    # springstarter config logging init "${@}"
    # _____________________________________________________
    "$curDir"/config/logging/logging_configurer.sh "init" "${@}"

    # _____________________________________________________
    # springstarter db init "${@}"
    # _____________________________________________________
    "$curDir"/db/db_configurer.sh "init" "$@"

    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${BLUE}${BOLD}[SPRINGSTARTER CONFIG INIT] Finished.${RESET}"
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
}

prompt() {
    subcommands="$curDir"/config/.commands

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
env)
    env "${@:2}"
    ;;
db)
    db "${@:2}"
    ;;
appyaml)
    echo -e
    echo -e "${GREEN}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${GREEN}${BOLD}[CONFIG] Application.yaml${RESET}"
    echo -e "${GREEN}${BOLD}______________________________________________________________________________________${RESET}"
    "$curDir"/config/appyaml/appyaml_configurer.sh "${@:2}"
    echo -e "${GREEN}${BOLD}______________________________________________________________________________________${RESET}"
    ;;
buildgradle)
    # "$curDir"/db/db_configurer.sh "${@:2}"
    ;;
metadata)
    # "$curDir"/env/env_configurer.sh "${@:2}"
    ;;
logging)
    echo -e
    echo -e "${GREEN}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${GREEN}${BOLD}[CONFIG] Logging${RESET}"
    echo -e "${GREEN}${BOLD}______________________________________________________________________________________${RESET}"
    "$curDir"/config/logging/logging_configurer.sh "${@:2}"
    echo -e "${GREEN}${BOLD}______________________________________________________________________________________${RESET}"
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
