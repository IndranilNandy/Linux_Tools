#!/usr/bin/env bash

update_etc_exports() {
    xargs -I X echo "grep -F \"X\" /etc/exports > /dev/null || echo \"X\" | sudo tee -a /etc/exports" | bash
}

create_non_existing_shares() {
    xargs -I X echo X | awk '{ print $1 }' | xargs -I X echo "[[ -d X ]] || sudo mkdir -p X" | bash
}

create_backup() {
    [[ -f /etc/exports-backup ]] || sudo cp /etc/exports /etc/exports-backup
}

# https://ubuntu.com/server/docs/service-nfs
config_server_setup() {
    create_backup

    cat ../config/server/.commons | update_etc_exports
    cat ../config/server/.commons | create_non_existing_shares
    
    host_specific_exportsfile=$(hostname)-$(hostname -I | awk '{ print $1 }')

    cat ../config/server/"$host_specific_exportsfile" | update_etc_exports
    cat ../config/server/"$host_specific_exportsfile" | create_non_existing_shares

    sudo exportfs -a
    sudo systemctl restart nfs-kernel-server.service
}

config_server_setup
