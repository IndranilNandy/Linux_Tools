#!/usr/bin/env bash

process_vars_mapping() {
    env_file=".env"
    mapping_file="compose.varsmapping"
    # xargs -I X echo "grep -E X $env_file | cut -d\"=\" -f2-" < "$compose_vars" | bash | xargs -I Y echo hi Y

    # This code is kept for reference, this is the longer version of the next one-liner code
    # for mapentry in $(cat "$mapping_file" | grep -v " *#"); do
    #     mapkey=$(echo "$mapentry" | awk -F'/' '{print $2}')
    #     mapvalue=$(echo "$mapentry" | awk -F'/' '{print $3}')
    #     # echo "$mapkey" "$mapvalue"
    #     env_value=$(grep -E "$mapvalue=" "$env_file" | grep -v " *#" | cut -d"=" -f2-)
    #     echo "s/$mapkey/$env_value/"
    # done

    xargs -I X echo "echo \"s/\$(echo X | awk -F'/' '{print \$2}')/\$(grep -E \$(echo X | awk -F'/' '{print \$3}')= "$env_file" | grep -v " \*#" | cut -d"=" -f2-)/\"" < "$mapping_file" | bash
}

process_template() {
    file="${1}"
    echo -e "[Compose][Postgres] Now substituting env variables in $file"
    sed -f <(process_vars_mapping) "$file"
}

find_db_container() {
    env_file=".env"
    mapping_file="compose.varsmapping"
    svc_key=$(grep -E "your-service-name" "$mapping_file" | grep -v " *#" | awk -F'/' '{print $3}')
    svc_value=$(grep -E "$svc_key" "$env_file" | grep -v " *#" | awk -F'=' '{print $2}')

    no=$(sudo -S docker ps | grep -c "$svc_value");
    (( no > 1)) && echo -e "WARNING! Multiple postgres containers running under same project [$svc_value]. Run 'docker compose up' manually." && return 1
    postgres_container=$(sudo -S docker ps --filter ancestor=postgres | grep "$svc_value" | awk '{print $NF}');

    echo $postgres_container
}

test() {
    c=$(find_db_container) || echo -e failed && return 1
    echo "$c"
    echo abc
}

test1() {
    target="/tmp/springstarter"
    mkdir -p "$target"
    script=init.sqltemplate
    # process_vars_mapping
    cp "$script" "$target"/init.sql && process_template "$target"/init.sql
    echo
    cat "$target"/init.sql
}

# process_vars_mapping
# find_db_container
test1