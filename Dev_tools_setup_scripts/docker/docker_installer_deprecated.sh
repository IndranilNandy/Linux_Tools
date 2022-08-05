#!/bin/bash
yes | sudo apt install docker.io
sudo usermod -aG docker ${USER}
echo "su - ${USER}"
su - ${USER}
id -nG 