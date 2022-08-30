#!/usr/bin/env bash


drain_nodes() {
    echo "Draining nodes"
    # TODO: implement later
    # kubectl drain <node name> --delete-emptydir-data --force --ignore-daemonsets
}

reset_tables() {
    sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X
    sudo ipvsadm -C
}

delete_nodes() {
    echo "Deleting nodes"
    # TODO: implement later
    # kubectl delete node <node name>
}

clean_CNI_config() {
    sudo rm -rf /etc/cni/net.d || return 1
    return 0
}

cleanup() {
    drain_nodes

    yes | sudo kubeadm reset
    reset_tables

    delete_nodes
    clean_CNI_config || echo -e "[CLEANUP] Failed to clean CNI configuration. This may lead to other issues. You may try to clean /etc/cni/net.d manually"
}

# Cleanup the cluster
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#tear-down

cleanup