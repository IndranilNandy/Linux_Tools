#!/usr/bin/env bash

install_dbeaver() {
    yes | sudo snap install dbeaver-ce
}

echo -e "Installing DBeaver" && install_dbeaver