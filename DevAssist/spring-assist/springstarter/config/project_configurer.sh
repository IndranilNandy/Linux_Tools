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

init1() {
    project_name="${@}"
    echo -e "project: $project_name"
    [[ ! -d "$(pwd)/$project_name" ]] && echo -e "Not able to find the project directory in the current directory. Exiting." && exit 1
    (
        cd "$(pwd)/$project_name" || exit 1
        # mkdir -p ".setup"
        # cp -r "$tmpdir"/config .setup

        springstarter env secrets dotenv load
        springstarter db init
    )
}

init() {
    # _____________________________________________________
    # springstarter env init "${@}"
    # _____________________________________________________
    "$curDir"/env/env_configurer.sh "init" "$@"

    # _____________________________________________________
    # springstarter db init "${@}"
    # _____________________________________________________
    "$curDir"/db/db_configurer.sh "init" "$@"

    # _____________________________________________________
    # springstarter config appyaml init "${@}"
    # _____________________________________________________
    "$curDir"/config/appyaml/appyaml_configurer.sh "init" "${@}"

    # _____________________________________________________
    # springstarter config logging init "${@}"
    # _____________________________________________________
    "$curDir"/config/logging/logging_configurer.sh "init" "${@}"

}

prompt() {
    subcommands="$curDir"/config/.commands

    cat "$subcommands" | nl
    read -p "Your choice: " no

    local choice=$(cat "$subcommands" | nl | head -n"$no" | tail -n1 | cut -f2)
    echo "Selected: $choice"

    "${0}" "$choice"
}

project_name=

case "${1}" in
init)
    init "${@:2}"
    ;;
env)
    springstarter env "${@:2}"
    ;;
db)
    springstarter db "${@:2}"
    ;;
appyaml)
    echo -e
    echo -e "${GREEN}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${GREEN}${BOLD}Application.yaml${RESET}"
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
    echo -e "${GREEN}${BOLD}Logging${RESET}"
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
