#!/usr/bin/env bash
. ./lib/k8_cluster_setup.lib

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
[[ "$nodetype" == "control" ]] && [[ "$cniplugin" == "d" ]] && echo -e "Invalid CNI plugin! CNI plugins supported are: [weavenet, calico]" && exit 1

echo 0 >STATUS
echo s: $(cat STATUS)

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin
! prereq_setup $nodetype && echo -e "[CLUSTER INITIALIZATION] Setup prerequisite check failed" && exit 1

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-runtime
! container_runtime_setup && echo -e "[CLUSTER INITIALIZATION] Container runtime setup failed" && exit 1

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
! kubectl_setup && echo -e "[CLUSTER INITIALIZATION] Kubectl setup failed" && exit 1
! kubelet_setup && echo -e "[CLUSTER INITIALIZATION] Kubelet setup failed" && exit 1
! kubeadm_setup $nodetype $cniplugin && echo -e "[CLUSTER INITIALIZATION] Kubeadm setup failed" && exit 1

# https://www.weave.works/docs/net/latest/kubernetes/kube-addon/#-installation
# https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart
pod_networking_setup $nodetype $cniplugin

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#control-plane-node-isolation
[[ "$nodetype" == "control" ]] && ! controlplane_config && echo -e "[CLUSTER INITIALIZATION] Probably issue with removing taint on control node!"

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#join-nodes
[[ "$nodetype" == "worker" ]] && ! join_worker && echo -e "[CLUSTER INITIALIZATION] Joining this worker failed!"

ret=$(cat STATUS)
rm STATUS

! [[ "$ret" == "0" ]] && echo -e "[CLUSTER INITIALIZATION] FAILED on $(hostname)!" && exit 1
echo -e "[CLUSTER INITIALIZATION] Finished on $(hostname)"
exit 0


