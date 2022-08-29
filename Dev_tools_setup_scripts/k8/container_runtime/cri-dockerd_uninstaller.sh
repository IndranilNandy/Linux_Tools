#!/usr/bin/env bash

yes | sudo apt purge --auto-remove cri-dockerd
sudo apt clean
yes | sudo apt autoremove
