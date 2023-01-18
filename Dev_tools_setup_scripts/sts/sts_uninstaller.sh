#!/usr/bin/env bash

remove_env_vars() {
    envloader="$MYCONFIGLOADER"/.envloader
    stshome=/opt
    stspath="$stshome"/sts

    sed -i "s@\(.*\):$stspath\(.*\)@\1\2@" "$envloader"
}

remove_symlink() {
    sudo rm "$MYCOMMANDSREPO"/sts
}

remove_binary() {
    rm -rf /opt/sts
}

remove_env_vars && remove_symlink && remove_binary || echo -e "[sts] Failed to uninstall"
