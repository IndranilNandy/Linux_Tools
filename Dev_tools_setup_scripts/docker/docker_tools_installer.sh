#!/usr/bin/env bash

# Ref: https://github.com/wagoodman/dive#installation
install_dive() {
    mkdir -p /tmp/dive-tool
    (
        cd /tmp/dive-tool || return 1
        wget https://github.com/wagoodman/dive/releases/download/v0.9.2/dive_0.9.2_linux_amd64.deb
        sudo apt install ./dive_0.9.2_linux_amd64.deb
    )
    rm -rf /tmp/dive-tool
}
install_tools() {
    install_dive || return 1
    return 0
}

install_tools || echo -e "One or more tools failed while installing"
