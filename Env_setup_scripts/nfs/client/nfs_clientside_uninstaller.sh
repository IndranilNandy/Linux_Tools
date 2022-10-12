#!/usr/bin/env bash

uninstall_nfs_client() {
    yes | sudo apt purge --auto-remove nfs-common
    sudo apt clean
    yes | sudo apt autoremove
}

uninstall_nfs_client