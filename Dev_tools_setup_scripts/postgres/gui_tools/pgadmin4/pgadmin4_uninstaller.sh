#!/usr/bin/env bash

uninstall_pgadmin4() {
    yes | sudo apt remove pgadmin4
    sudo apt clean
    yes | sudo apt autoremove
}

uninstall_pgadmin4
