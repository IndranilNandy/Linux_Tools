#!/bin/bash
sudo apt update && (yes|sudo apt install git)
./configurer/git_configurer.sh
./gcm_installer.sh