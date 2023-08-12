#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

default_yamls() {
    resources="src/main/resources"
    yaml_store="config"
    mapping_file="$curDir"/config/appyaml/configuration/.yaml-tag-mapping

    [[ ! -d "$resources" ]] && echo -e "${RED}Not able to find 'resources' folder. This command should be run from the project root folder.${RESET}" && return 1
    [[ -d "$(pwd)"/"$yaml_store" ]] || mkdir -p "$(pwd)"/"$yaml_store"

    echo -e "Each default YAML file will be created inside $yaml_store with its vscode snippet as content."
    echo -e "As each YAML is opened with CODE, put the cursor at the end of the snippet and press 'CTRL' + SPACE. Select the snippet and save the YAML."

    for mapentry in $(cat "$mapping_file" | grep -v "^$" | grep -v " *#"); do
        yaml_name=$(echo "$mapentry" | awk -F'|' '{print $1}')
        yaml_snippet=$(echo "$mapentry" | awk -F'|' '{print $2}')

        [[ -f "$(pwd)"/"$yaml_store"/"$yaml_name" ]] || echo "$yaml_snippet" > "$(pwd)"/"$yaml_store"/"$yaml_name"
        code -w "$(pwd)"/"$yaml_store"/"$yaml_name"
    done
}

empty_yaml() {
    resources="src/main/resources"
    [[ ! -d "$resources" ]] && echo -e "${RED}Not able to find 'resources' folder. This command should be run from the project root folder.${RESET}" && return 1
    [[ -f "$resources"/application.yaml ]] && echo -e "${RED}application.yaml already exists in the 'resources' folder. Hence, not replacing it.${RESET}" && return 1

    touch "$resources"/application.yaml && echo -e "${YELLOW}DO NOT FORGET to use 4 spaces for a tab in application.yaml${RESET}"
    code "$resources"/application.yaml
    read -p "Did you change it? [y/n].. " ans

    if [[ $(echo "$ans" | tr [:upper:] [:lower:]) == "y" ]]; then
        echo -e "${GREEN}Empty application.yaml file created.${RESET}"
    else
        echo -e "${RED}Change it later.${RESET}"
    fi
    return 0
}

create() {
    default_yamls "${@}"

}

prompt() {
    subcommands="$curDir"/config/appyaml/.commands

    cat "$subcommands" | nl
    read -p "Your choice: " no

    local choice=$(cat "$subcommands" | nl | head -n"$no" | tail -n1 | cut -f2)
    echo "Selected: $choice"

    "${0}" "$choice"
}

init() {
    echo -e
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${BLUE}${BOLD}[SPRINGSTARTER CONFIG APPYAML INIT] Started.${RESET}"
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"

    # _____________________________________________________
    # springstarter config appyaml default "${@}"
    # _____________________________________________________
    default_yamls "${@}"

    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${BLUE}${BOLD}[SPRINGSTARTER CONFIG APPYAML INIT] Finished.${RESET}"
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
}

case "${1}" in
init)
    init "${@:2}"
    ;;
create)
    create "${@:2}"
    ;;
default)
    echo -e
    echo -e "-----------------------------------"
    echo -e "Default YAML configuration"
    echo -e "-----------------------------------"
    default_yamls "${@:2}"
    ;;
empty)
    echo -e
    echo -e "-----------------------------------"
    echo -e "Creating empty application.yaml"
    echo -e "-----------------------------------"
    empty_yaml "${@:2}"
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