#!/usr/bin/env bash

remove_taint() {
    echo -e "[CONTROLPLANE CONFIGURATION] Removing taint on control plane node"
    kubectl taint nodes --all node-role.kubernetes.io/control-plane-
}

show_all_cluster_nodes() {
    echo -e "[CONTROLPLANE CONFIGURATION] List of all custer nodes"
    kubectl get nodes -o wide
}

# Schedule pods on control plane
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#control-plane-node-isolation
remove_taint
show_all_cluster_nodes

echo -e "[CONTROLPLANE CONFIGURATION] Configuration completed and Control plane is ready now"

exit 0
