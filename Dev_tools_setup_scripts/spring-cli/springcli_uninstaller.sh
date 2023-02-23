#!/usr/bin/env bash

remove_env_vars() {
    myshpath remove --path="$HOME/spring-boot-cli/spring-3.0.0-M5/bin" --export="SPRING_HOME=$HOME/spring-boot-cli/spring-3.0.0-M5"
}

remove_autocompletion() {
    sudo rm /etc/bash_completion.d/spring
}

remove_binary() {
    rm -rf "$HOME"/spring-boot-cli
}

remove_env_vars && remove_autocompletion && remove_binary || echo -e "[spring-cli] Failed to uninstall"