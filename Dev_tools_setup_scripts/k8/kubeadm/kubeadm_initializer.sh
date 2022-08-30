#!/usr/bin/env bash

initialize_kubeadm() {
    # This is for Weavenet
    # sudo kubeadm init --pod-network-cidr=10.10.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock

    # This is for Calico
    sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock
}

access_kubeconfig() {
    mkdir -p $HOME/.kube
    yes | sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

init_cluster() {
    initialize_kubeadm || return 1
    access_kubeconfig
}

! init_cluster && echo "[KUBEADM]FAILED!! Kubeadm cluster initialization failed. Cluster may already be initialized" && exit 1
exit 0
