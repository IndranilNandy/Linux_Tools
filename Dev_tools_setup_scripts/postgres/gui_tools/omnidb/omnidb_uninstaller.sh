#!/usr/bin/env bash

uninstall_omnidb() {
    yes | sudo apt remove omnidb-app omnidb-server omnidb-plpgsql-debugger
    sudo apt clean
    yes | sudo apt autoremove
}

uninstall_omnidb
