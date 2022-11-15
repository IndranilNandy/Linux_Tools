#!/usr/bin/env bash

# https://docs.spring.io/spring-boot/docs/1.2.0.M2/reference/html/getting-started-installing-spring-boot.html#getting-started-manual-cli-installation
installer() {
    mkdir tmp
    (
        cd tmp || return

        wget -O spring-boot-cli.tar.gz "https://repo.spring.io/artifactory/milestone/org/springframework/boot/spring-boot-cli/3.0.0-M5/spring-boot-cli-3.0.0-M5-bin.tar.gz"
        mkdir -p "$HOME"/spring-boot-cli
        tar xvzf spring-boot-cli.tar.gz -C "$HOME"/spring-boot-cli
    )
    rm -rf tmp
}

add_env_var() {
    envloader="$MYCONFIGLOADER"/.envloader
    springhome="$HOME/spring-boot-cli/spring-3.0.0-M5"
    exp_springhome="export SPRING_HOME=$springhome"

    springpath="$springhome"/bin
    expPath="export PATH=$PATH"

    (echo "$expPath" | grep -E -v " *#" | grep -q "$springpath") || expPath="$expPath":"$springpath"
    if grep -v " *#" "$envloader" | grep -q -E "export PATH" ; then
        sed -i "s#\(export PATH=.*\)#$expPath#" "$envloader"
    else
        echo "$expPath" >>"$envloader"
    fi

    (grep -v " *#" "$envloader" | grep -q -E "$exp_springhome") || echo "$exp_springhome" >>"$envloader"
}

add_shell_completion() {
    springhome="$HOME/spring-boot-cli/spring-3.0.0-M5"
    sudo ln -s "$springhome"/shell-completion/bash/spring /etc/bash_completion.d/spring
}

installer && add_env_var && add_shell_completion || echo -e "[spring-cli] Failed to install"
