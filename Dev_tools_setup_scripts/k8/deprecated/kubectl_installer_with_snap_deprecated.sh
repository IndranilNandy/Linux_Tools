#!/usr/bin/env bash

installer() {
    # https://kubernetes.io/docs/tasks/tools/install-kubectl-linux
    snap install kubectl --classic
    kubectl version --client
    # kubectl cluster-info
}

(ifinstalled kubectl && echo "kubectl already installed") || installer
./components/kubectl_configurer.sh
