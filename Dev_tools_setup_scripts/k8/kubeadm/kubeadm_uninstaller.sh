#!/usr/bin/env bash

yes | sudo apt purge --auto-remove kubeadm
sudo apt clean
yes | sudo apt autoremove