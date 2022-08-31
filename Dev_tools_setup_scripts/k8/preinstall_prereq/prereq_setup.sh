#!/usr/bin/env bash

get_mac() {
    cat /sys/class/net/eth0/address
}

verify_unique_mac() {
    echo MAC addr: $(get_mac)
}

verify_unique_product_uuid() {
    echo Product_uuid: $(sudo cat /sys/class/dmi/id/product_uuid)
}

if_port_unavailable() {
    nc -z 127.0.0.1 ${1}
}

# https://kubernetes.io/docs/reference/ports-and-protocols/#control-plane
control_plane_ports() {
    cp_ports=(6443 2379 2380 10250 10259 10257)

    for p in "${cp_ports[@]}"; do
        if_port_unavailable "$p" && echo -e "Port $p not available. Reassign ports. Exiting" && return 1
    done
    return 0
}

# https://kubernetes.io/docs/reference/ports-and-protocols/#node
worker_node_ports() {
    worker_ports=(10250 {30000..32767})
    for p in "${worker_ports[@]}"; do
        if_port_unavailable "$p" && echo -e "Port $p not available. Reassign ports. Exiting" && return 1
    done
    return 0
}

check_ports() {
    if [[ "${1}" == "control" ]]; then
        control_plane_ports
    else
        worker_node_ports
    fi
}

if_swap_on() {
    cat /proc/swaps | grep -q swap
}

disable_swap_for_session() {
    echo -e "Disabling swap for this session"
    sudo swapoff -a
}

disable_swap_permanently() {
    sudo sed -i '/ swap / s/^/#/' /etc/fstab
}

disable_swap() {
    if_swap_on && disable_swap_permanently
    if_swap_on && disable_swap_for_session
    if_swap_on && return 1 || echo -e "SWAP disabled."
    return 0
}

check_min_cpucores_availability() {
    cores_available=$(cat /proc/cpuinfo | grep "cpu cores" | sed "s/.*: \(.\)/\1/")
    min_cores_required=2
    [[ "$min_cores_required" -le "$cores_available " ]] || return 1
    return 0
}

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin
! check_min_cpucores_availability && echo -e "[PREREQ] FAILED!! Not enough cpu core available. Min required 2" && exit 1

# Verify unique mac and product_uuid accross all nodes
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#verify-mac-address
# TODO: Current implementation doesn't check for uniqueness across all nodes, it just fetchces information. This check has to be done in future

! verify_unique_mac && echo -e "[PREREQ] FAILED!! No unique MAC" && exit 1
! verify_unique_product_uuid && echo -e "[PREREQ] FAILED!! No unique product uuid" &&  exit 1

# Check required ports
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports

! check_ports ${1} && echo -e "[PREREQ] FAILED!! Ports being used" &&  exit 1

# Disable SWAP
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin
! disable_swap && echo -e "[PREREQ] FAILED!! Swap is ON" && exit 1

exit 0