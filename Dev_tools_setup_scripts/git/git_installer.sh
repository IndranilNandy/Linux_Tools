#!/bin/bash

[[ -n $(which git) ]] || (sudo apt update && (yes | sudo apt install git))

./configurer/git_configurer.sh
ifinstalled gcmcore || ./gcm_installer.sh
