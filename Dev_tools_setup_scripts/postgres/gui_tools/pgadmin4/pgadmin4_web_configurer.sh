#!/usr/bin/env bash

setup_web() {
    sudo /usr/pgadmin4/bin/setup-web.sh
}

echo -e "Configuring web setup for pgAdmin4" && setup_web
