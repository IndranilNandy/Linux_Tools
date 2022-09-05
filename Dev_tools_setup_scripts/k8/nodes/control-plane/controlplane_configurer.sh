#!/usr/bin/env bash

remove_taint() {
    echo -e "[CONTROLPLANE CONFIGURATION] Removing taint on control plane node"
    kubectl taint nodes --all node-role.kubernetes.io/control-plane- || return 1
}

show_all_cluster_nodes() {
    echo -e "[CONTROLPLANE CONFIGURATION] List of all custer nodes"
    kubectl get nodes -o wide
}

show_all_cluster_nodes

echo -e "[CONTROLPLANE CONFIGURATION] Configuration completed and Control plane is ready now"

# Schedule pods on control plane
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#control-plane-node-isolation
! remove_taint && echo -e "[CONTROLPLANE CONFIGURATION] Failed to remove taint on control plane" && exit 1

exit 0
