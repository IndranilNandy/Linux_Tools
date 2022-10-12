#!/usr/bin/env bash

# https://ubuntu.com/server/docs/service-nfs
install_nfs_client() {
    ifinstalled nfs-common > /dev/null || yes | sudo apt install nfs-common
}

install_nfs_client
./nfs_clientside_configurer.sh