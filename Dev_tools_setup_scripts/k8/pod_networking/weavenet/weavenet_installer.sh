#!/usr/bin/env bash

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network

install_weavenet() {
    kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')" || return 1
    return 0
}

verify_pod_network() {
    echo -e "Waiting for 40 secs to verify pod network"
    sleep 40
    kubectl get pods --all-namespaces | grep Running | grep coredns || return 1
    echo -e "Pod network verification done"
}

# https://www.weave.works/docs/net/latest/kubernetes/kube-addon/#-installation
! install_weavenet && echo -e "[WEAVENET] FAILED!! Weave net installation failed" && exit 1
! verify_pod_network && echo -e "[WEAVENET] FAILED!! Weave net pod network not working. You may increase waiting time for verification"

exit 0
