#!/usr/bin/env bash

# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#install-and-configure-prerequisites

load_br_netfilter() {
    lsmod | grep br_netfilter || sudo modprobe br_netfilter
}

check_iptables_entries() {
    sysctl net.bridge.bridge-nf-call-iptables | grep "= 1$" || return 1
    sysctl net.bridge.bridge-nf-call-ip6tables | grep "= 1$" || return 1
    sysctl net.ipv4.ip_forward | grep "= 1$" || return 1
}

config_sysctl() {
    check_iptables_entries && return 0

    cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

    sudo modprobe overlay
    sudo modprobe br_netfilter

    # sysctl params required by setup, params persist across reboots
    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

    # Apply sysctl params without reboot
    sudo sysctl --system
}

# Assumption: Docker used as container runtime
check_cgroup_driver() {
    docker info | grep "Cgroup Driver" | grep systemd || return 1
}

! load_br_netfilter && echo -e "[Container Runtime] FAILED!! br_netfilter not loaded" && exit 1
! config_sysctl && echo -e "[Container Runtime] FAILED!! Issue with iptables" && exit 1
# check_cgroup_driver || echo "Docker is not configured to use systemd as cgroup driver. FAILED!!"
! check_cgroup_driver && echo -e "[Container Runtime] FAILED!! Docker cgroup driver not set to systemd" && exit 1
exit 0
