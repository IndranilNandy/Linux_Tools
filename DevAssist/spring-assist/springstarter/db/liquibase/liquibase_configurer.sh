#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

config_default() {
    liquibase_config_path="$(pwd)"/config/database/tools/dmt/liquibase
    changelog_dir="changelogs"
    properties_activites_dir="properties/activities"

    [[ ! -f "$(pwd)"/build.gradle ]] && echo -e "${RED}Not able to find build.gradle, this command should be run from the project root folder.${RESET}" && return 1
    [[ -d "$liquibase_config_path"/"$changelog_dir" ]] || mkdir -p "$liquibase_config_path"/"$changelog_dir"
    [[ -d "$liquibase_config_path"/"$properties_activites_dir" ]] || mkdir -p "$liquibase_config_path"/"$properties_activites_dir"

    [[ -f "$liquibase_config_path"/"$changelog_dir"/db-changelog-root.sql ]] || touch "$liquibase_config_path"/"$changelog_dir"/db-changelog-root.sql

    [[ -d "$liquibase_config_path"/"$properties_activites_dir"/main ]] || mkdir -p "$liquibase_config_path"/"$properties_activites_dir"/main
    [[ -d "$liquibase_config_path"/"$properties_activites_dir"/gen ]] || mkdir -p "$liquibase_config_path"/"$properties_activites_dir"/gen
    [[ -d "$liquibase_config_path"/"$properties_activites_dir"/diffHb ]] || mkdir -p "$liquibase_config_path"/"$properties_activites_dir"/diffHb

    [[ -f "$liquibase_config_path"/"$properties_activites_dir"/main/liquibase.properties ]] || touch "$liquibase_config_path"/"$properties_activites_dir"/main/liquibase.properties
    [[ -f "$liquibase_config_path"/"$properties_activites_dir"/gen/liquibase.properties ]] || touch "$liquibase_config_path"/"$properties_activites_dir"/gen/liquibase.properties
    [[ -f "$liquibase_config_path"/"$properties_activites_dir"/diffHb/liquibase.properties ]] || touch "$liquibase_config_path"/"$properties_activites_dir"/diffHb/liquibase.properties

    echo -e "Successfully created Liquibase configuration in $liquibase_config_path"
    return 0;
}

init() {
    echo -e
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${BLUE}${BOLD}[SPRINGSTARTER DB LIQUIBASE INIT] Started.${RESET}"
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"

    config_default "$@"

    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${BLUE}${BOLD}[SPRINGSTARTER DB GEN LIQUIBASE] Finished.${RESET}"
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"

    return 0;
}

prompt() {
    subcommands="$curDir"/db/liquibase/.commands

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
config)
    echo -e
    echo -e "-----------------------------------"
    echo -e "Liquibase configuration"
    echo -e "-----------------------------------"
    config_default "${@:2}"
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
