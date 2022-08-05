#!/usr/bin/env bash

yes | sudo apt-get remove docker docker-engine docker.io containerd runc
yes | sudo apt-get remove docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo apt clean
yes | sudo apt autoremove
[[ -e /etc/apt/keyrings/docker.gpg ]] && (yes | sudo rm /etc/apt/keyrings/docker.gpg)
