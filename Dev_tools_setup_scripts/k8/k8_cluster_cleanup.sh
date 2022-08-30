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
cleanup() {
    drain_nodes

    yes | sudo kubeadm reset
    reset_tables

    delete_nodes
}

# Cleanup the cluster
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#tear-down

cleanup