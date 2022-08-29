#!/usr/bin/env bash

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin
# ./preinstall_prereq/prereq_setup.sh
(cd preinstall_prereq && ./prereq_setup.sh)

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-runtime
# ./cri-dockerd_installer.sh
# ./container_runtime/container_runtime_setup.sh
(cd container_runtime && ./container_runtime_setup.sh)

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
# ./kubeadm_kubelet_kubectl_installer.sh
(cd kubectl && ./kubectl_installer.sh)
(cd kubelet && ./kubelet_installer.sh)
(cd kubeadm && ./kubeadm_installer.sh)
