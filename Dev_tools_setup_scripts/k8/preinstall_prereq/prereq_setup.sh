#!/usr/bin/env bash

get_mac() {
    cat /sys/class/net/eth0/address
}

verify_unique_mac() {
    get_mac
}

verify_unique_product_uuid() {
    sudo cat /sys/class/dmi/id/product_uuid
}

if_port_unavailable() {
    nc -z 127.0.0.1 ${1}
}

# https://kubernetes.io/docs/reference/ports-and-protocols/#control-plane
control_plane_ports() {
    cp_ports=(6443 2379 2380 10250 10259 10257 3389)

    for p in "${cp_ports[@]}"; do
        # echo "$p"
        if_port_unavailable "$p" && echo -e "Port $p not available. Reassign ports. Exiting" && return 1
    done
    return 0
}

# https://kubernetes.io/docs/reference/ports-and-protocols/#node
worker_node_ports() {
    worker_ports=(10250 {30000..32767})
    for p in "${worker_ports[@]}"; do
        # echo "$p"
        if_port_unavailable "$p" && echo -e "Port $p not available. Reassign ports. Exiting" && return 1
    done
    return 0
}

check_ports() {
    read -n 1 -p "If it is Control plane [c] or Worker node [w] - " type
    echo -e

    [[ "$type" == "c" ]] && control_plane_ports
    [[ "$type" == "w" ]] && worker_node_ports

}

# Verify unique mac and product_uuid accross all nodes
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#verify-mac-address
# TODO: Current implementation doesn't check for uniqueness across all nodes, it just fetchces information. This check has to be done in future

verify_unique_mac || exit 1
verify_unique_product_uuid || exit 1

# Check required ports
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports

check_ports || exit 1
