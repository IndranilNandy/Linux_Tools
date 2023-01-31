#!/bin/bash

[[ -n $(which git) ]] || (sudo apt update && (yes | sudo apt install git))

./configurer/git_configurer.sh
# ifinstalled gcmcore || ./gcm_installer.sh
dpkg-query -l gcm > /dev/null && echo -e "GCM is already installed and configured" || ./gcm_installer.sh
