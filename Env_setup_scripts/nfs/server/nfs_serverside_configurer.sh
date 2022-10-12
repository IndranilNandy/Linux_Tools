#!/usr/bin/env bash

# https://ubuntu.com/server/docs/service-nfs
config_server_setup() {
    cat ../config/server/.exports | xargs -I X echo "grep -F \"X\" /etc/exports > /dev/null || echo \"X\" | sudo tee -a /etc/exports" | bash
    cat ../config/server/.exports | xargs -I X echo X | awk '{ print $1 }' | xargs -I X echo "[[ -d X ]] || sudo mkdir -p X" | bash
    
    sudo exportfs -a
    sudo systemctl restart nfs-kernel-server.service
}

config_server_setup
