#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

liquibase() {
    "$curDir"/db/liquibase/liquibase_configurer.sh "$@"
}

gen() {
    "$curDir"/db/gen/db_gen_configurer.sh "$@"
}

mysql() {
    "$curDir"/db/mysql/mysql_configurer.sh "$@"
}

pgsql() {
    "$curDir"/db/pgsql/pgsql_configurer.sh "$@"
}

init() {
    echo -e
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${BLUE}${BOLD}[SPRINGSTARTER DB INIT] Started.${RESET}"
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"

    # _____________________________________________________
    # springstarter db postgresql init "${@}"
    # _____________________________________________________
    "$curDir"/db/pgsql/pgsql_configurer.sh "init" "$@"

    # _____________________________________________________
    # springstarter db gen init "${@}"
    # _____________________________________________________
    "$curDir"/db/gen/db_gen_configurer.sh "init" "$@"

    # _____________________________________________________
    # springstarter db liquibase init "${@}"
    # _____________________________________________________
    "$curDir"/db/liquibase/liquibase_configurer.sh "init" "$@"

    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${BLUE}${BOLD}[SPRINGSTARTER DB INIT] Finished.${RESET}"
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
}

prompt() {
    subcommands="$curDir"/db/.commands

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
postgresql)
    pgsql "${@:2}"
    ;;
mysql)
    mysql "${@:2}"
    ;;
gen)
    gen "${@:2}"
    ;;
liquibase)
    liquibase "${@:2}"
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
