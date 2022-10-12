#!/usr/bin/env bash

create_non_existing_mounts() {
    xargs -I X echo X | awk '{ print $2 }' | xargs -I X echo "[[ -d X ]] || sudo mkdir -p X" | bash
}

mount_all_shares() {
    xargs -I X echo X | awk '{ print "sudo mount "$1" "$2  }' | bash
}

# https://ubuntu.com/server/docs/service-nfs
config_client_setup() {
    cat ../config/client/.commons | create_non_existing_mounts
    cat ../config/client/.commons | mount_all_shares
    
    host_specific_exportsfile=$(hostname)-$(hostname -I | awk '{ print $1 }')

    cat ../config/client/"$host_specific_exportsfile" | create_non_existing_mounts
    cat ../config/client/"$host_specific_exportsfile" | mount_all_shares
}

config_client_setup
