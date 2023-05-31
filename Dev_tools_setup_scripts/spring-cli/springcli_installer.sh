#!/usr/bin/env bash

# https://docs.spring.io/spring-boot/docs/1.2.0.M2/reference/html/getting-started-installing-spring-boot.html#getting-started-manual-cli-installation
installer() {
    [[ -d "$HOME"/spring-boot-cli ]] && echo -e "Since directory \"spring-boot-cli\" already exists, assuming that the binary is already installed." && return 0
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
    myshpath add --path="$HOME/spring-boot-cli/spring-3.0.0-M5/bin" --export="SPRING_HOME=$HOME/spring-boot-cli/spring-3.0.0-M5"
}

add_shell_completion() {
    springhome="$HOME/spring-boot-cli/spring-3.0.0-M5"
    yes | sudo ln -s -i "$springhome"/shell-completion/bash/spring /etc/bash_completion.d/spring
}

installer && add_env_var && add_shell_completion || echo -e "[spring-cli] Failed to install"