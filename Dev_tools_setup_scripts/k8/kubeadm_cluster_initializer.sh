#!/usr/bin/env bash
. ./k8_cluster_setup.lib

nodetype=d
cniplugin=d

for arg in "$@"; do
    case $arg in
    --node=*)
        [[ $(echo "$arg" | sed "s/--node=\(.*\)/\1/") == "control" ]] && nodetype=c
        [[ $(echo "$arg" | sed "s/--node=\(.*\)/\1/") == "worker" ]] && nodetype=w
        ;;
    --cni=*)
        [[ $(echo "$arg" | sed "s/--cni=\(.*\)/\1/") == "weavenet" ]] && cniplugin=weavenet
        [[ $(echo "$arg" | sed "s/--cni=\(.*\)/\1/") == "calico" ]] && cniplugin=calico
        ;;
    *) ;;
    esac
done

case ${1} in
--node=*)
    [[ $(echo ${1} | sed "s/--node=\(.*\)/\1/") == "control" ]] && nodetype=control
    [[ $(echo ${1} | sed "s/--node=\(.*\)/\1/") == "worker" ]] && nodetype=worker
    ;;
*) ;;
esac

[[ "$nodetype" == "d" ]] && echo -e "Invalid nodetype! Nodetype should be either control or worker" && exit 1
[[ "$cniplugin" == "d" ]] && echo -e "Invalid CNI plugin! CNI plugins supported are: [weavenet, calico]" && exit 1

echo 0 >STATUS
echo s: $(cat STATUS)

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin
prereq_setup $nodetype

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-runtime
container_runtime_setup

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
kubectl_setup
kubelet_setup
kubeadm_setup $nodetype $cniplugin

# https://www.weave.works/docs/net/latest/kubernetes/kube-addon/#-installation
# https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart
pod_networking_setup $nodetype $cniplugin

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#control-plane-node-isolation
[[ "$nodetype" == "control" ]] && controlplane_config

[[ $(cat STATUS) == "0" ]] || echo "CLUSTER NOT INITIALIZED!"

rm STATUS
