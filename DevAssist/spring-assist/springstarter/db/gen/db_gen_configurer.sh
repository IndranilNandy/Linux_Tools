#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

schema() {
    resources="src/main/resources"
    schema_store="generated/jpa/schema"

    [[ ! -d "$resources" ]] && echo -e "${RED}Not able to find 'resources' folder. This command should be run from the project root folder.${RESET}" && return 1
    [[ -d "$(pwd)"/"$schema_store" ]] || mkdir -p "$(pwd)"/"$schema_store"

    echo -e "${RED}You need to add $schema_store to .gitignore${RESET}"
    echo -e "Add the following lines to .gitignore\n"
    echo -e "### Ignore jpa generated schema ###\n$schema_store/"
    code -w ".gitignore"

    echo -e "${RED}\nIf you're executing 'schema' command only, then you need to run 'springstarter config appyaml init' to configure application yamls, if not done already.${RESET}"
    return 0;
}

dml() {
    resources="src/main/resources"
    hb_init="hb-db-init"
    spring_init="spring-db-init"

    [[ ! -d "$resources" ]] && echo -e "${RED}Not able to find 'resources' folder. This command should be run from the project root folder.${RESET}" && return 1
    [[ -d "$resources"/"$hb_init" ]] || mkdir -p "$resources"/"$hb_init"
    [[ -d "$resources"/"$spring_init" ]] || mkdir -p "$resources"/"$spring_init"

    [[ -f "$resources"/"$hb_init"/import-script-01.sql ]] || touch "$resources"/"$hb_init"/import-script-01.sql
    [[ -f "$resources"/"$hb_init"/import-script-02.sql ]] || touch "$resources"/"$hb_init"/import-script-02.sql

    [[ -f "$resources"/"$spring_init"/data-postgresql-01.sql ]] || touch "$resources"/"$spring_init"/data-postgresql-01.sql
    [[ -f "$resources"/"$spring_init"/data-postgresql-02.sql ]] || touch "$resources"/"$spring_init"/data-postgresql-02.sql
    [[ -f "$resources"/"$spring_init"/schema-postgresql-01.sql ]] || touch "$resources"/"$spring_init"/schema-postgresql-01.sql
    [[ -f "$resources"/"$spring_init"/schema-postgresql-02.sql ]] || touch "$resources"/"$spring_init"/schema-postgresql-02.sql

    echo -e "Created (if not already exists)"
    echo -e "${RED}\nIf you're executing 'dml' command only, then you need to run 'springstarter config appyaml init' to configure application yamls, if not done already.${RESET}"
    return 0
}

ddl() {
    echo -e "Nothing to do."
    echo -e "${RED}\nIf you're executing 'ddl' command only, then you need to run 'springstarter config appyaml init' to configure application yamls, if not done already.${RESET}"
}

init() {
    echo -e
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${BLUE}${BOLD}[SPRINGSTARTER DB GEN INIT] Started.${RESET}"
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"

    # _____________________________________________________
    # springstarter db postgresql init "${@}"
    # _____________________________________________________
    "$curDir"/db/pgsql/pgsql_configurer.sh "init" "$@"

    ddl "$@" || return 1
    dml "$@" || return 1
    schema "$@" || return 1

    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${BLUE}${BOLD}[SPRINGSTARTER DB GEN INIT] Finished.${RESET}"
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"

    return 0;
}

prompt() {
    subcommands="$curDir"/db/gen/.commands

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
ddl)
    echo -e
    echo -e "-----------------------------------"
    echo -e "DDL configuration"
    echo -e "-----------------------------------"
    ddl "${@:2}"
    ;;
dml)
    echo -e
    echo -e "-----------------------------------"
    echo -e "DML configuration"
    echo -e "-----------------------------------"
    dml "${@:2}"
    ;;
schema)
    echo -e
    echo -e "-----------------------------------"
    echo -e "Schema generator configuration"
    echo -e "-----------------------------------"
    schema "${@:2}"
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
