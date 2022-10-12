#!/usr/bin/env bash

# https://ubuntu.com/server/docs/service-nfs
install_nfs_server() {
    ifinstalled nfs-kernel-server > /dev/null || yes | sudo apt install nfs-kernel-server
}

install_nfs_server
./nfs_serverside_configurer.sh