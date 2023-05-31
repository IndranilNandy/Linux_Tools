#!/usr/bin/env bash

uninstall_postgresql() {
    yes | sudo apt purge --auto-remove postgresql postgresql-*
    sudo apt clean
    yes | sudo apt autoremove
}

./gui_tools/pgadmin4/pgadmin4_uninstaller.sh
./gui_tools/dbeaver/dbeaver_uninstaller.sh
uninstall_postgresql