#!/usr/bin/env bash

# Ref. http://www.squirrelsql.org/?r=qal-sqle#installation
install_squirrel() {

    mkdir -p /tmp/squirrel
    (
        cd /tmp/squirrel || return 1
        wget -O squirrel.jar https://github.com/squirrel-sql-client/squirrel-sql-stable-releases/releases/download/4.6.0-installer/squirrel-sql-4.6.0-standard.jar
        java -jar squirrel.jar
    )
    rm -rf /tmp/squirrel

    path=$(find "$HOME" -path "$HOME"/thinclient_drives -prune -false -o -name "squirrel-sql.sh")
    yes | sudo ln -s -i "$path" "$MYCOMMANDSREPO"/squirrel
}

echo -e "Installing SQuirrel SQL Client..." && install_squirrel