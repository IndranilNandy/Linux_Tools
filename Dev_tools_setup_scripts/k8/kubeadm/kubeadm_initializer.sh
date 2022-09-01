#!/usr/bin/env bash

initialize_controlplane() {
    echo "[KUBEADM] Initializing kubeadm on control plane node with pod network: ${1}"

    # This is for Weavenet
    [[ "${1}" == "weavenet" ]] && sudo kubeadm init --pod-network-cidr=10.10.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock && echo "weavenet" && return 0

    # This is for Calico
    [[ "${1}" == "calico" ]] && sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock && echo "calico" && return 0
    return 0
}

access_kubeconfig() {
    mkdir -p $HOME/.kube
    yes | sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    return 0
}

initialize_workernode() {
    # echo "Initialize worker node here"
    echo -e
}

init_cluster() {
    echo "init_cluster ${1}"
    if [[ "${1}" == "control" ]]; then
        initialize_controlplane "${2}" || return 1
        access_kubeconfig
    else
        initialize_workernode
    fi
    return 0

}

! init_cluster $* && echo "[KUBEADM] FAILED!! Kubeadm cluster initialization failed. Cluster may already be initialized" && exit 1
exit 0
