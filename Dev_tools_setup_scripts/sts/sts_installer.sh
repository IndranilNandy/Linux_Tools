#!/usr/bin/env bash

installer() {
    mkdir tmp
    (
        cd tmp || return

        wget -O sts.tar.gz "https://download.springsource.com/release/STS4/4.16.1.RELEASE/dist/e4.25/spring-tool-suite-4-4.16.1.RELEASE-e4.25.0-linux.gtk.x86_64.tar.gz"
        mkdir -p "$HOME"/sts
        tar xvzf sts.tar.gz -C "$HOME"/sts
    )
    rm -rf tmp
}

add_env_var() {
    envloader="$MYCONFIGLOADER"/.envloader
    stshome="$HOME"/sts

    stspath="$stshome"/"sts-4.16.1.RELEASE"
    expPath="export PATH=$PATH"

    yes | sudo ln -s -i "$stspath"/SpringToolSuite4 "$MYCOMMANDSREPO"/sts

    (echo "$expPath" | grep -E -v " *#" | grep -q "$stspath") && return 0
    expPath="$expPath":"$stspath"

    if grep -v " *#" "$envloader" | grep -q -E "export PATH" ; then
        sed -i "s#\(export PATH=.*\)#$expPath#" "$envloader"
    else
        echo "$expPath" >>"$envloader"
    fi
}

installer
add_env_var

