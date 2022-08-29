#!/usr/bin/env bash

installer() {
    # Update the apt package index and install packages needed to use the Kubernetes apt repository
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl

    # Download the Google Cloud public signing key
    sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

    # Add the Kubernetes apt repository
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

    # Update apt package index, install kubelet, kubeadm and kubectl, and pin their version
    sudo apt-get update
    sudo apt-get install -y kubectl
    sudo apt-mark hold kubectl
}

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
ifinstalled kubectl || installer
./kubectl_configurer.sh
# ./kubelet_configurer.sh