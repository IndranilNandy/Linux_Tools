#!/usr/bin/env bash

# Ref. https://docs.liquibase.com/start/install/liquibase-linux.html
installer() {
    [[ -d "$HOME"/liquibase ]] && echo -e "Since directory \"liquibase\" already exists, assuming that the binary is already installed." && return 0
    tempdir="/tmp/liquibase"

    mkdir "$tempdir"
    (
        cd "$tempdir" || return

        # Releases link: https://github.com/liquibase/liquibase/releases
        wget -O liquibase.tar.gz "https://github.com/liquibase/liquibase/releases/download/v4.23.1/liquibase-4.23.1.tar.gz"
        mkdir -p "$HOME"/liquibase
        tar xvzf liquibase.tar.gz -C "$HOME"/liquibase
    )
    rm -rf "$tempdir"
}

add_env_var() {
    myshpath add --path="$HOME/liquibase"
}

add_shell_completion() {
    liquibasehome="$HOME/liquibase"
    yes | sudo ln -s -i "$liquibasehome"/lib/liquibase_autocomplete.sh /etc/bash_completion.d/liquibase
}

# validate_and_install() {
#     desktop-file-validate sts.desktop && sudo desktop-file-install sts.desktop
# }

(installer && add_env_var && add_shell_completion) || echo -e "Error in installing Liquibase"
