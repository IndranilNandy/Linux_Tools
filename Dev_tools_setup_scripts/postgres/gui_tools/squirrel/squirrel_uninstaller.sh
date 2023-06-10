#!/usr/bin/env bash

uninstall_squirrel() {
    path=$(dirname "$(find "$HOME" -path "$HOME"/thinclient_drives -prune -false -o -name "squirrel-sql.jar")")/Uninstaller
    java -jar "$path"/uninstaller.jar
    sudo rm "$MYCOMMANDSREPO"/squirrel

    read -p "Want to delete configuration directory (.squirrel-sql) [Y/N]" reply
    ! [[ "$reply" == "Y" ]] && ! [[ "$reply" == "y" ]] && exit 1
    sudo rm -rf "$HOME"/".squirrel-sql"
}

echo -e "Uninstalling SQuirrel SQL Client..." && uninstall_squirrel
