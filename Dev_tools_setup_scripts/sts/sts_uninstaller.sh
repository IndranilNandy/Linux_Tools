#!/usr/bin/env bash

#!/usr/bin/env bash

remove_env_vars() {
    envloader="$MYCONFIGLOADER"/.envloader
    stshome="$HOME"/sts
    stspath="$stshome"/"sts-4.16.1.RELEASE"

    sed -i "s@\(.*\):$stspath\(.*\)@\1\2@" "$envloader"
}

remove_symlink() {
    sudo rm "$MYCOMMANDSREPO"/sts
}

remove_binary() {
    rm -rf "$HOME"/sts
}

remove_env_vars && remove_symlink && remove_binary || echo -e "[sts] Failed to uninstall"