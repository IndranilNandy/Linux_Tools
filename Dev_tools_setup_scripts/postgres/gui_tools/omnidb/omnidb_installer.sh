#!/usr/bin/env bash

# Ref. https://omnidb.readthedocs.io/en/latest/en/02_installation.html
# Ref. https://github.com/OmniDB/OmniDB/releases
install_omnidb() {
    mkdir -p /tmp/omnidb
    (
        cd /tmp/omnidb || return 1
        wget https://github.com/OmniDB/OmniDB/releases/download/3.0.3b/omnidb-app_3.0.3b_linux_x86_64.deb
        wget https://github.com/OmniDB/OmniDB/releases/download/3.0.3b/omnidb-server_3.0.3b_linux_x86_64.deb
        wget https://github.com/OmniDB/OmniDB/releases/download/3.0.3b/omnidb-plpgsql-debugger_3.0.3b_linux_x86_64.deb

        sudo apt install ./omnidb-app_3.0.3b_linux_x86_64.deb
        sudo apt install ./omnidb-server_3.0.3b_linux_x86_64.deb
        sudo apt install ./omnidb-plpgsql-debugger_3.0.3b_linux_x86_64.deb
    )
    rm -rf /tmp/omnidb
}

validate_and_install() {
    desktop-file-validate omnidb.desktop && sudo desktop-file-install omnidb.desktop
    return 0;
}

install_omnidb && validate_and_install
