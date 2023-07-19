#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

script_path="$LINUX_TOOLS_spring_helper"/Db_related/postgresql_container_creator
script="$script_path"/docker-compose.yaml
target_compose_path="$(pwd)"/docker/postgresql
env_file="$(pwd)"/.env
config_root="$curDir"/db/pgsql/container
help_dir="$config_root"/help
mapping_file="$config_root"/configuration/compose.varsmapping
sql_template_path="$config_root"/configuration/templates
sql_template_ext=".pgsql.template"
sel_template=

find_key_value() {
    key="${1}"

    svc_key=$(grep -E "$key" "$mapping_file" | grep -v " *#" | awk -F'/' '{print $3}')
    svc_value=$(grep -E "$svc_key" "$env_file" | grep -v " *#" | awk -F'=' '{print $2}')
    echo "$svc_value"
}

find_db_container() {
    svc_value=$(find_key_value "your-service-name")
    img_name=$(find_key_value "your-sql-image")

    no=$(docker ps --filter ancestor="$img_name" | grep -c "$svc_value")
    ((no > 1)) && echo -e "WARNING! Multiple postgres containers running under same project [$svc_value]. Run 'docker compose up' manually." && return 1
    postgres_container=$(docker ps --filter ancestor="$img_name" | grep "$svc_value" | awk '{print $NF}')

    echo "$postgres_container"
}

findSqlTemplate() {
    fn_arg="${1}"
    search_path=
    if [[ "$fn_arg" == "templatestore" ]]; then
        search_path="$sql_template_path"
    elif [[ "$fn_arg" == "localdir" ]]; then
        search_path="$(pwd)"
    fi

    find "$search_path" -name "*$sql_template_ext" >/tmp/sqltemplist
    count_of_templates=$(cat /tmp/sqltemplist | wc -l)

    ((count_of_templates == 0)) && echo -e "No SqlTemplate found in the current directory hierarchy. Exiting." && return 1

    if ((count_of_templates == 1)); then
        sel_template="$(cat /tmp/sqltemplist)"
    else
        echo -e "Multiple SqlTemplates found in the current directory hierarchy!"
        cat /tmp/sqltemplist | nl

        read -p "Which SqlTemplate to choose? Enter the number: " no
        sel_template=$(cat /tmp/sqltemplist | nl | head -n$no | tail -n1 | cut -f2)
    fi

    rm /tmp/sqltemplist
    echo "Selected template = $sel_template"
    return 0
}

configContainer() {
    echo -e
    echo -e "-----------------------------------"
    echo -e "Configuring containers"
    echo -e "-----------------------------------"

    target_init_sql=$(find_key_value "your-sql-scriptstore")
    mkdir -p "$target_init_sql"

    script="$sql_template_path"/default.pgsql.template # default template

    for arg in "$@"; do
        case "$arg" in
        --sqltemplate=templatestore)
            findSqlTemplate "templatestore" || return 1
            script="$sel_template"
            ;;
        --sqltemplate=localdir)
            findSqlTemplate "localdir" || return 1
            script="$sel_template"
            ;;
        --sqltemplate=*)
            script=$(echo "$arg" | awk -F'=' '{print $2}')
            [[ ! -f "$script" ]] && echo -e "${RED}[WARNING!] Invalid template.\n[Failed!] Skipping configuration.${RESET}" && return 1
            ;;
        *)
            script="$sql_template_path"/default.pgsql.template # default template
            ;;
        esac
    done
    cp "$script" "$(pwd)"/init.sql && process_template "$(pwd)"/init.sql &&
        echo -e "\nVerify init.sql file. It'll be automatically deleted after compose-up." &&
        editor -w "$(pwd)"/init.sql && sudo cp "$(pwd)"/init.sql "$target_init_sql"/init.sql &&
        rm "$(pwd)"/init.sql

    postgres_container=$(find_db_container) || return 1
    user=postgres
    db=postgres

    echo -e "db container: $postgres_container -->running--> docker exec -i $postgres_container bash -c \"sleep 5 && psql postgresql://$user@localhost:5432/$db < /scriptstore/init.sql\""

    docker exec -i "$postgres_container" bash -c "echo \"Waiting for 10 secs for db to come live\" && sleep 5 && psql postgresql://$user@localhost:5432/$db < /scriptstore/init.sql"
    sudo rm "$target_init_sql"/init.sql

    return 0
}

composeUp() {
    echo -e "\nRunning 'docker compose up -d'"
    docker compose -f "$target_compose_path"/docker-compose.yaml up -d
}

process_vars_mapping() {
    # This code is kept for reference, this is the longer version of the next one-liner code
    # for mapentry in $(cat "$mapping_file"); do
    #     mapkey=$(echo "$mapentry" | awk -F'/' '{print $2}')
    #     mapvalue=$(echo "$mapentry" | awk -F'/' '{print $3}')

    #     env_value=$(grep -E "$mapvalue=" "$env_file" | grep -v " *#" | cut -d"=" -f2-)
    #     echo "s/$mapkey/$env_value/"
    # done

    xargs -I X echo "echo \"s#\$(echo X | awk -F'/' '{print \$2}')#\$(grep -E \$(echo X | awk -F'/' '{print \$3}')= "$env_file" | grep -v " \*#" | cut -d"=" -f2-)#\"" <"$mapping_file" | bash
}

process_template() {
    file="${1}"
    echo -e "Substituting env variables in $file"
    sed -i -f <(process_vars_mapping) "$file"

}

copyContainerScript() {
    # echo -e "[DB][Postgres] Copying compose template and substituting env variables"
    # echo -e "[DB][Postgres] Target path: $target_compose_path"

    [[ -d "$target_compose_path" ]] || mkdir -p "$target_compose_path"
    [[ -f "$target_compose_path"/docker-compose.yaml ]] && return 0

    cp "$script" "$target_compose_path" && process_template "$target_compose_path"/docker-compose.yaml && echo -e "\nVerify docker-compose file!" && editor -w "$target_compose_path"/docker-compose.yaml || return 1
    echo -e "Compose file created in target path [$target_compose_path]"

    return 0
}

upContainer() {
    copyContainerScript || return 1
    composeUp || return 1
    return 0
}

init() {
    echo -e
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${BLUE}${BOLD}[SPRINGSTARTER DB POSTGRESQL CONTAINER INIT] Started.${RESET}"
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"

    echo -e
    echo -e "-----------------------------------"
    echo -e "Initializing containers"
    echo -e "-----------------------------------"
    [[ -f "$target_compose_path"/docker-compose.yaml ]] &&
        echo -e "${YELLOW}[DB][Postgres] docker-compose.yaml already exists.\
        \nHence not fetching/replacing it from scriptstore. This will run 'docker compose up -d' and rerun the db initialization script.\
        \nIf you intend for 'init', you need to first run 'clean' and delete local docker-compose.yaml, or, you may manually run 'docker compose down' and then delete local docker-compose.yaml.${RESET} \
        \n${RED}Remember running 'clean' with --f option or manually deleting docker-compose.yaml will delete all your local changes on docker-compose.yaml. You may want to create a backup first.${RESET}"
    [[ ! -f "$env_file" ]] && echo -e ".env file is missing in the root directory. Skipping container setup" && return 1

    upContainer || return 1
    configContainer "$@" || return 1
    echo -e "\nDONE"

    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"
    echo -e "${BLUE}${BOLD}[SPRINGSTARTER DB POSTGRESQL CONTAINER INIT] Finished.${RESET}"
    echo -e "${BLUE}${BOLD}______________________________________________________________________________________${RESET}"

    return 0
}

config() {
    configContainer "$@" || return 1
    return 0
}

up() {
    docker compose -f "$target_compose_path"/docker-compose.yaml up -d && echo -e "All services are UP. Done!"
    echo -e "${RED}[Advice] If you've already run 'init', then you DO NOT need any special command for this. Instead use 'docker compose up -d'.\nOtherwise, use 'init' command.${RESET}"
}

down() {
    docker compose -f "$target_compose_path"/docker-compose.yaml down && echo -e "All services are down. Done!"
    echo -e "${RED}Volumes are NOT cleaned. If you want, you need to do it manually.${RESET}"
}

clean() {
    opt="${1}"

    if [[ ! -f "$target_compose_path"/docker-compose.yaml ]]; then
        echo -e "NOT FOUND ->" "$target_compose_path"/docker-compose.yaml "\nProbably, the services are already down. Check it manually." && return 1
    fi

    case "$opt" in
    --f)
        down

        rm "$target_compose_path"/docker-compose.yaml
        echo "DELETED ->" "$target_compose_path"/docker-compose.yaml
        ;;
    *)
        echo -e "${RED}[WARNING!!!] docker-compose.yaml MAY CONTAIN your LCOAL CHANGES! Do you really want to clean it? \
        \nRemember, 'init' will fetch a fresh temmplate, substituted by all env variables. This will delete all your local changes on docker-compose.yaml. You may want to create a backup first.${RESET}"
        read -p "SHOULD I DELETE? [y/n]..." ans
        down

        if [[ $(echo "$ans" | tr [:upper:] [:lower:]) == "y" ]]; then
            rm "$target_compose_path"/docker-compose.yaml
            echo "DELETED ->" "$target_compose_path"/docker-compose.yaml
        else
            echo "NOT DELETED ->" "$target_compose_path"/docker-compose.yaml
        fi
        ;;
    esac
}

help() {
    cat "$help_dir"/pgsql_container_configurer.help
}

prompt() {
    subcommands="$curDir"/db/pgsql/container/.commands

    cat "$subcommands" | nl
    read -p "Your choice: " no

    local choice=$(cat "$subcommands" | nl | head -n"$no" | tail -n1 | cut -f2)
    echo "Selected: $choice"

    "${0}" "$choice"
}

case "${1}" in
init)
    echo -e "______________________________________________________________________________________"
    echo -e "[DB][Postgres] INIT"
    echo -e "______________________________________________________________________________________"
    init "${@:2}"
    echo -e "______________________________________________________________________________________"
    ;;
up)
    echo -e "______________________________________________________________________________________"
    echo -e "[DB][Postgres] UP"
    echo -e "______________________________________________________________________________________"
    up "${@:2}"
    echo -e "______________________________________________________________________________________"
    ;;
down)
    echo -e "______________________________________________________________________________________"
    echo -e "[DB][Postgres] DOWN"
    echo -e "______________________________________________________________________________________"
    down "${@:2}"
    echo -e "______________________________________________________________________________________"
    ;;
config)
    echo -e "______________________________________________________________________________________"
    echo -e "[DB][Postgres] CONFIG"
    echo -e "______________________________________________________________________________________"
    config "${@:2}"
    echo -e "______________________________________________________________________________________"
    ;;
clean)
    echo -e "______________________________________________________________________________________"
    echo -e "[DB][Postgres] CLEAN ""${*:2}"
    echo -e "______________________________________________________________________________________"
    clean "${@:2}"
    echo -e "______________________________________________________________________________________"
    ;;
help)
    help
    ;;
'')
    prompt
    ;;
*)
    help
    ;;
esac
