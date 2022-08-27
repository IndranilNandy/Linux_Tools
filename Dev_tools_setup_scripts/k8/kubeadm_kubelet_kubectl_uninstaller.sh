#!/usr/bin/env bash

yes | sudo apt purge --auto-remove kubelet kubeadm kubectl
sudo apt clean
yes | sudo apt autoremove