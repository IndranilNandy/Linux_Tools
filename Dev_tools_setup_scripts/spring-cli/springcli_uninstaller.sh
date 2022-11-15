#!/usr/bin/env bash

remove_env_vars() {
    envloader="$MYCONFIGLOADER"/.envloader
    springhome="$HOME/spring-boot-cli/spring-3.0.0-M5"
    exp_springhome="export SPRING_HOME=$springhome"

    springpath="$springhome"/bin
    # expPath="export PATH=$PATH"

    sed -i "\,^$exp_springhome$,d" "$envloader"
    sed -i "s@\(.*\):$springpath\(.*\)@\1\2@" "$envloader"
}

remove_autocompletion() {
    sudo rm /etc/bash_completion.d/spring
}

remove_binary() {
    rm -rf "$HOME"/spring-boot-cli
}

remove_env_vars && remove_autocompletion && remove_binary || echo -e "[spring-cli] Failed to uninstall"