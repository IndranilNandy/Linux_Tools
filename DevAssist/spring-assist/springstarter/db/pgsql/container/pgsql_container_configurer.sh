#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

script_path="$LINUX_TOOLS_spring_helper"/Db_related/postgresql_container_creator
script="$script_path"/docker-compose.yaml

target_path="$(pwd)"/docker/postgresql

copyContainerScript() {

    [[ -d "$target_path" ]] || mkdir -p "$target_path"
    [[ -f "$target_path"/docker-compose.yaml ]] && echo -e "Warning! docker-compose.yaml already exists, hence not copying. You can edit it manually." ||
        ( cp "$script" "$target_path" && editor -w "$target_path"/docker-compose.yaml )
}

composeUp() {
    docker compose -f "$target_path"/docker-compose.yaml up -d
}

upContainer() {
    copyContainerScript
    composeUp
}

init() {
    echo "from init -> ""$*"
    upContainer
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
