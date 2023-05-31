#!/usr/bin/env bash

uninstall_postgresql() {
    yes | sudo apt purge --auto-remove postgresql postgresql-*
    sudo apt clean
    yes | sudo apt autoremove
}

uninstall_postgresql
