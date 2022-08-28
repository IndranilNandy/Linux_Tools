#!/usr/bin/env bash

sudo rm /usr/local/bin/kubectl-convert
yes | sudo apt purge --auto-remove kubelet kubeadm kubectl
sudo apt clean
yes | sudo apt autoremove