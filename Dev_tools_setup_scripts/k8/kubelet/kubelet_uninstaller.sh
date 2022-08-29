#!/usr/bin/env bash

yes | sudo apt purge --auto-remove kubelet
sudo apt clean
yes | sudo apt autoremove