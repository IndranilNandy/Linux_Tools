#!/usr/bin/env bash

initialize_controlplane() {
    echo "[KUBEADM] Initializing kubeadm on control plane node with pod network: ${1}"

    # This is for Weavenet
    if [[ "${1}" == "weavenet" ]]; then
     ! sudo kubeadm init --pod-network-cidr=10.10.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock && echo "[KUBEADM] Initializing kubeadm on control plane node with pod network [weavenet] failed" && return 1
    fi

    # This is for Calico
    if [[ "${1}" == "calico" ]]; then
     ! sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock && echo "[KUBEADM] Initializing kubeadm on control plane node with pod network [calico] failed" && return 1
    fi

    return 0
}

access_kubeconfig() {
    mkdir -p $HOME/.kube || return 1
    yes | sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config || return 1
    sudo chown $(id -u):$(id -g) $HOME/.kube/config || return 1
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
        access_kubeconfig || return 1
    else
        initialize_workernode
    fi
    return 0

}

! init_cluster $* && echo "[KUBEADM] FAILED!! Kubeadm cluster initialization failed. Check for already existing cluster" && exit 1
exit 0
