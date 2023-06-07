#!/usr/bin/env bash

setup_web() {
    sudo /usr/pgadmin4/bin/setup-web.sh
}

read -p "Want to proceed with configuring web setup for pgAdmin4? [Y/N]" reply
[[ "$reply" == "Y" ]] || [[ "$reply" == "y" ]] || exit 1

echo -e "Configuring web setup for pgAdmin4" && setup_web
