#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

create() {
    echo -e "${RED}Yet to be implemented.${RESET}"
}

default() {
    resources="src/main/resources"
    [[ ! -d "$resources" ]] && echo -e "${RED}Not able to find 'resources' folder. This command should be run from the project root folder.${RESET}" && return 1
    [[ -f "$resources"/log4j2.yaml ]] && echo -e "${RED}log4j2.yaml already exists in the 'resources' folder. Hence, not replacing it.${RESET}" && return 1

    # cp "$LINUX_TOOLS_logging_config"/log4j2.yaml "$resources"/
    cp "$LINUX_TOOLS_logging_config"/log4j2-empty-sample.yaml "$resources"/ &&
        echo -e "We are INTENTIONALLY copying and keeping an empty yaml file under 'resources' folder. Read the empty YAML file comments for more details"
    cp "$LINUX_TOOLS_logging_config"/log4j2.sample.yaml "$resources"/

    echo -e "Opening $resources/log4j2-empty-sample.yaml" && code "$resources"/log4j2.yaml
    echo -e "Opening $resources/log4j2.sample.yaml" && code "$resources"/log4j2.sample.yaml

    echo -e "${YELLOW}DO NOT FORGET to use 4 spaces for a tab in log4j2.yaml${RESET}"
    read -p "Did you change it to 4? [y/n].. " ans

    if [[ $(echo "$ans" | tr [:upper:] [:lower:]) == "y" ]]; then
        echo -e "${GREEN}log4j2.yaml and log4j2.sample.yaml files created.${RESET}"
    else
        echo -e "${RED}Change it later.${RESET}"
    fi

    echo -e "Now copying java-properties files samples to facilitate log4j2 composite configuration. Read the empty YAML file comments for more details."
    cp -i "$LINUX_TOOLS_logging_config"/custom_config/java-properties/* "$resources"/

    logconfig="log-config"
    echo -e "Now copying sample YAML files to facilitate log4j2 composite configuration"
    [[ -d "$curDir"/"$logconfig" ]] || mkdir "$logconfig"
    cp -i "$LINUX_TOOLS_logging_config"/custom_config/log-config/* "$logconfig"/

    echo -e "${RED}DO NOT FORGET TO UPDATE CORRESPONDING PARAMETERS IN THESE CONFIGURATION YAML FILES. As examples, see below.${RESET}"
    echo -e "log4j2-spring-root.yaml -> Update packagename, groupid and artifactid"
    echo -e "log4j2-spring-controller/service/repository/model.yaml -> Update the loggers' names with your application's package-names (e.g. you may have 'repo' instead of 'repository')"

    return 0
}

init() {
    echo -e
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${BLUE}${BOLD}[SPRINGSTARTER CONFIG LOGGING LOG4J2 INIT] Started.${RESET}"
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"

    # _____________________________________________________
    # springstarter config logging log4j2 default "${@}"
    # _____________________________________________________
    default "${@}"

    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${BLUE}${BOLD}[SPRINGSTARTER CONFIG LOGGING LOG4J2 INIT] Finished.${RESET}"
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
}

prompt() {
    subcommands="$curDir"/config/logging/log4j2/.commands

    cat "$subcommands" | nl
    read -p "Your choice: " no

    local choice=$(cat "$subcommands" | nl | head -n"$no" | tail -n1 | cut -f2)
    echo "Selected: $choice"

    "${0}" "$choice"
}

case "${1}" in
init)
    echo -e
    echo -e "-----------------------------------"
    echo -e "Log4j2 -- INIT"
    echo -e "-----------------------------------"
    init "${@:2}"
    ;;
default)
    echo -e
    echo -e "-----------------------------------"
    echo -e "Log4j2 -- Default"
    echo -e "-----------------------------------"
    default "${@:2}"
    ;;
create)
    create "${@:2}"
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
