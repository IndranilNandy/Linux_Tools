#!/usr/bin/env bash

installer() {
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
    envloader="$MYCONFIGLOADER"/.envloader
    stshome=/opt

    stspath="$stshome"/sts
    expPath="export PATH=$PATH"

    yes | sudo ln -s -i "$stspath"/SpringToolSuite4 "$MYCOMMANDSREPO"/sts

    (echo "$expPath" | grep -E -v " *#" | grep -q "$stspath") && return 0
    expPath="$expPath":"$stspath"

    if grep -v " *#" "$envloader" | grep -q -E "export PATH"; then
        sed -i "s#\(export PATH=.*\)#$expPath#" "$envloader"
    else
        echo "$expPath" >>"$envloader"
    fi
}

validate_and_install() {
    desktop-file-validate sts.desktop && sudo desktop-file-install sts.desktop
}

(installer && add_env_var && validate_and_install) || echo -e "Error in installing Spring Tool Suite"
