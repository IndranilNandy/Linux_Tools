#!/usr/bin/env bash

# TODO: After uninstallation, still it is accessible from Activities
remove_toolbox() {
    sudo rm -rf /opt/jetbrains-toolbox
    sudo rm /usr/local/bin/jetbrains-toolbox
}

remove_toolbox