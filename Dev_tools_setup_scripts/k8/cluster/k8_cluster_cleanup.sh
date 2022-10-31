#!/usr/bin/env bash

drain_node() {
    echo "Draining node ${1}"
    # TODO: implement later
    # kubectl drain <node name> --delete-emptydir-data --force --ignore-daemonsets

    ! kubectl drain "${1}" --delete-emptydir-data --force --ignore-daemonsets && echo -e "[TEARDOWN] Failed to drain worker node ${1}" && return 1

    # workers=$(cat ./config/.clusterconfig | grep "workers:" | sed "s/workers: *\(.*\)/\1/" | tr " *" "\n" | xargs -I X echo X)
    # for w in $workers; do
    #     # sshpass -p "$passwd"
    #     ! kubectl drain "$w" --delete-emptydir-data --force --ignore-daemonsets && echo -e "[PREREQ] Failed to drain worker nodes" && return 1
    # done
    return 0
}

reset_tables() {
    sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X
    sudo ipvsadm -C
}

delete_node() {
    echo "Deleting node ${1}"
    ! kubectl delete node "${1}" && echo -e "[TEARDOWN] Failed to delete worker node ${1}" && return 1
    return 0
}

clean_CNI_config() {
    sudo rm -rf /etc/cni/net.d || return 1
    return 0
}

cleanup() {
    # drain_nodes

    yes | sudo kubeadm reset --cri-socket=unix:///var/run/cri-dockerd.sock || echo -e "[TEARDOWN] Failed to reset kubeadm"
    reset_tables
    # || echo -e "[TEARDOWN] Failed to reset iptables"

    # delete_nodes
    clean_CNI_config || echo -e "[TEARDOWN] Failed to clean CNI configuration. This may lead to other issues. You may try to clean /etc/cni/net.d manually"
}

# Tear down the cluster
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#tear-down

teardown_cluster() {
    node_c=$(cat ./config/.clusterconfig | grep "controlplane:" | sed "s/controlplane: *\(.*\)/\1/" | tr " *" "\n" | xargs -I X echo X)

    # This should be executed on Control Plane
    if [[ $(hostname) == "$node_c" ]]; then
        echo -e "[TEAR CONTROLPLANE] Logged in control plane $(hostname)"

        node_ws=$(cat ./config/.clusterconfig | grep "workers:" | sed "s/workers: *\(.*\)/\1/" | tr " *" "\n" | xargs -I X echo X)
        echo -e "[TEAR CONTROLPLANE] Starting to iterate over all worker nodes [drain -> delete -> kubeadm reset]"

        for w in $node_ws; do
            #echo -e
            [[ "$k8_tear_allnodes" == "true" ]] && ans="y" || read -p "Want to tear down worker node $w [y] or [n].. " ans
            if [[ $(echo $ans | tr [:upper:] [:lower:]) == "y" ]]; then
                drain_node "$w" || echo -e "[TEAR CONTROLPLANE] Failed to drain worker node $w. Still proceeding with deleting node"
                delete_node "$w" || echo -e "[TEAR CONTROLPLANE] Failed to delete worker node $w. Still proceeding with kubeadm reset"
                (./nodes/worker-node/worker_tear.sh "$w" || echo -e "[TEARDOWN] Failed to reset kubeadm in worker node $w. Proceeding with next worker node if available.")
            fi
        done

        echo -e "\n[TEAR CONTROLPLANE] Finished iterating over all worker nodes [drain -> delete -> kubeadm reset]. Next turn for control plane $node_c"

        [[ "$k8_tear_allnodes" == "true" ]] && ans="y" || read -p "Want to tear down the control plane [y] or [n].. " ans
        if [[ $(echo $ans | tr [:upper:] [:lower:]) == "n" ]]; then
            echo -e "[TEAR CONTROLPLANE] Not tearing down control plane"
            return 0
        fi
    fi

    # This should be executed on Control Plane and all worker nodes
    echo -e "[Cleaning up $(hostname)] kubeadm reset -> reset iptables -> clean CNI config"
    cleanup
    echo -e "[Cleaning up $(hostname)] Finished"
}

teardown_cluster
exit 0
