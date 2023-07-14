#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

script_path="$LINUX_TOOLS_spring_helper"/Db_related/postgresql_container_creator
script="$script_path"/docker-compose.yaml

target_path="$(pwd)"/docker/postgresql

find_db_container() {
    env_file=".env"
    mapping_file="$curDir"/db/pgsql/container/compose.varsmapping
    svc_key=$(grep -E "your-service-name" "$mapping_file" | grep -v " *#" | awk -F'/' '{print $3}')
    svc_value=$(grep -E "$svc_key" "$env_file" | grep -v " *#" | awk -F'=' '{print $2}')

    no=$(sudo -S docker ps --filter ancestor=postgres | grep -c "$svc_value");
    (( no > 1)) && echo -e "WARNING! Multiple postgres containers running under same project [$svc_value]. Run 'docker compose up' manually." && return 1
    postgres_container=$(sudo -S docker ps --filter ancestor=postgres | grep "$svc_value" | awk '{print $NF}');

    echo "$postgres_container"
}

configContainer() {
    # psql postgresql://"$role_admin"@localhost:"$port"/"$db" <'./dbinit_scripts/init.sql'
    echo -e "[Compose][Postgres] Now configuring containers"

    postgres_container=$(find_db_container) || return 1
    user=postgres
    db=postgres

    echo -e "[Compose][Postgres] db container -> $postgres_container"
    echo -e "[Compose][Postgres] Configuring db >> docker exec -i $postgres_container bash -c \"psql postgresql://$user@localhost:5432/$db -c '\l'\""

    docker exec -i "$postgres_container" bash -c "psql postgresql://$user@localhost:5432/$db -c '\l'"
    return 0
}

composeUp() {
    echo -e "[Compose][Postgres] Running 'docker compose up -d'"
    docker compose -f "$target_path"/docker-compose.yaml up -d
}

process_vars_mapping() {
    env_file=$(pwd)/.env
    mapping_file="$curDir"/db/pgsql/container/compose.varsmapping

    # echo -e "[Compose][Postgres][Mapping] Compose vaiable -> Env variable"
    # cat "$mapping_file"

    # xargs -I X echo "grep -E X $env_file | cut -d\"=\" -f2-" < "$compose_vars" | bash | xargs -I Y echo hi Y

    # This code is kept for reference, this is the longer version of the next one-liner code
    # for mapentry in $(cat "$mapping_file"); do
    #     mapkey=$(echo "$mapentry" | awk -F'/' '{print $2}')
    #     mapvalue=$(echo "$mapentry" | awk -F'/' '{print $3}')

    #     env_value=$(grep -E "$mapvalue" "$env_file" | grep -v " *#" | cut -d"=" -f2-)
    #     echo "s/$mapkey/$env_value/"
    # done

    xargs -I X echo "echo \"s/\$(echo X | awk -F'/' '{print \$2}')/\$(grep -E \$(echo X | awk -F'/' '{print \$3}') "$env_file" | grep -v " \*#" | cut -d"=" -f2-)/\"" < "$mapping_file" | bash
}

process_template() {
    file="${1}"
    echo -e "[Compose][Postgres] Now substituting env variables in $file"
    sed -i -f <(process_vars_mapping) "$file"

}

copyContainerScript() {
    echo -e "[Compose][Postgres] Copying compose template and substituting env variables"
    echo -e "[Compose][Postgres] Target path: $target_path"

    [[ -d "$target_path" ]] || mkdir -p "$target_path"
    [[ -f "$target_path"/docker-compose.yaml ]] && echo -e "Warning! docker-compose.yaml already exists, hence not copying. You can edit it manually." && return 0
    [[ ! -f $(pwd)/.env ]] && echo -e ".env file is missing in the root directory. Skipping container setup" && return 1

    cp "$script" "$target_path" && process_template "$target_path"/docker-compose.yaml && editor -w "$target_path"/docker-compose.yaml || return 1
    echo -e "[Compose][Postgres] Compose file created in target path [$target_path]"

    return 0
}

upContainer() {
    copyContainerScript || return 1
    composeUp || return 1
    return 0
}

init() {
    echo -e "[Compose][Postgres] Initializing containers"
    upContainer || return 1
    configContainer || return 1
    return 0
}

up() {
    echo "from up -> ""$*"
    # "$curDir"/db/pgsql/container/pgsql_container_configurer.sh "${@:2}"
}

down() {
    docker compose -f "$target_path"/docker-compose.yaml down

}

case "${1}" in
init)
    init "${@:2}"
    ;;
up)
    up "${@:2}"
    ;;
down)
    down "${@:2}"
    ;;
*)
    echo "--help"
    ;;
esac
