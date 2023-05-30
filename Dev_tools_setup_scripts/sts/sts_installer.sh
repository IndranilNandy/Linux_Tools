#!/usr/bin/env bash

installer() {
    [[ -d /opt/sts ]] && echo -e "Since directory \"/opt/sts\" already exists, assuming that the binary is already installed." && return 0

    mkdir tmp
    (
        cd tmp || return

        wget -O sts.tar.gz "https://download.springsource.com/release/STS4/4.16.1.RELEASE/dist/e4.25/spring-tool-suite-4-4.16.1.RELEASE-e4.25.0-linux.gtk.x86_64.tar.gz"
        sudo mkdir -p /opt/sts
        sudo tar xvf sts.tar.gz --one-top-level=/opt/sts --strip-components 1
    )
    rm -rf tmp
}

add_env_var() {
    yes | sudo ln -s -i "/opt/sts/SpringToolSuite4" "$MYCOMMANDSREPO"/sts
    myshpath add --path="/opt/sts"
}

validate_and_install() {
    desktop-file-validate sts.desktop && sudo desktop-file-install sts.desktop
}

(installer && add_env_var && validate_and_install) || echo -e "Error in installing Spring Tool Suite"
