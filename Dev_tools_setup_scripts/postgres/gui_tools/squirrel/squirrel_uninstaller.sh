#!/usr/bin/env bash

uninstall_squirrel() {
    path=$(dirname "$(find "$HOME" -path "$HOME"/thinclient_drives -prune -false -o -name "squirrel-sql.jar")")/Uninstaller
    java -jar "$path"/uninstaller.jar
    sudo rm "$MYSCRIPTREFS"/squirrel
}

echo -e "Uninstalling SQuirrel SQL Client..." && uninstall_squirrel