#!/usr/bin/env bash

download_postgresql_driver() {
    path="$HOME"/db-drivers/jdbc/postgresql
    [[ -d "$path" ]] || mkdir -p "$path"

    url="https://jdbc.postgresql.org/download/postgresql-42.6.0.jar"

    (
        cd "$path"
        wget "$url"
    )
}

# TODO: Should be in squirrel java class path,
update-env() {
    myshpath add --path="$HOME"/db-drivers/jdbc/postgresql
}

read -p "Want to proceed with downloading pgJDBC driver? [Y/N]" reply
[[ "$reply" == "Y" ]] || [[ "$reply" == "y" ]] || exit 1

download_postgresql_driver
# update-env