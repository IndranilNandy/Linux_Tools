#!/usr/bin/env bash

echo 0 > STATUS
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin
[[ $(cat STATUS) == "1" ]] || (cd preinstall_prereq && ./prereq_setup.sh || echo 1 > ../STATUS)

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-runtime
[[ $(cat STATUS) == "1" ]] || (cd container_runtime && ./container_runtime_setup.sh || echo 1 > ../STATUS)

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
[[ $(cat STATUS) == "1" ]] || (cd kubectl && ./kubectl_installer.sh || echo 1 > ../STATUS)
[[ $(cat STATUS) == "1" ]] || (cd kubelet && ./kubelet_installer.sh || echo 1 > ../STATUS)
[[ $(cat STATUS) == "1" ]] || (cd kubeadm && ./kubeadm_installer.sh || echo 1 > ../STATUS)

[[ $(cat STATUS) == "0" ]] || echo "CLUSTER NOT INITIALIZED!"

rm STATUS