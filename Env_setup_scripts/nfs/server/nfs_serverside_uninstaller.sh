#!/usr/bin/env bash

uninstall_nfs() {
    yes | sudo apt purge --auto-remove nfs-kernel-server
    sudo apt clean
    yes | sudo apt autoremove
}

uninstall_nfs