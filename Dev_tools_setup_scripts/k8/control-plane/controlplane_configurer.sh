#!/usr/bin/env bash

remove_taint() {
    kubectl taint nodes --all node-role.kubernetes.io/control-plane-
}

show_all_cluster_nodes() {
    kubectl get nodes -o wide
}

# Schedule pods on control plane
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#control-plane-node-isolation
remove_taint
show_all_cluster_nodes
exit 0