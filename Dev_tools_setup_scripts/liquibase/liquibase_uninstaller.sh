#!/usr/bin/env bash

remove_env_vars() {
    myshpath remove --path="$HOME/liquibase"
}

remove_autocompletion() {
    sudo rm /etc/bash_completion.d/liquibase
}

remove_binary() {
    rm -rf "$HOME"/liquibase
}

remove_env_vars && remove_autocompletion && remove_binary || echo -e "[liquibase] Failed to uninstall"