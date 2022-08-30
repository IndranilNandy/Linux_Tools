#!/usr/bin/env bash

echo 0 > STATUS
echo s: $(cat STATUS)
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin
[[ $(cat STATUS) == "1" ]] || (cd preinstall_prereq && ./prereq_setup.sh || echo 1 > ../STATUS)
echo a: $(cat STATUS)

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-runtime
[[ $(cat STATUS) == "1" ]] || (cd container_runtime && ./container_runtime_setup.sh || echo 1 > ../STATUS)
echo b: $(cat STATUS)

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
[[ $(cat STATUS) == "1" ]] || (cd kubectl && ./kubectl_installer.sh || echo 1 > ../STATUS)
echo c: $(cat STATUS)

[[ $(cat STATUS) == "1" ]] || (cd kubelet && ./kubelet_installer.sh || echo 1 > ../STATUS)
echo d: $(cat STATUS)

[[ $(cat STATUS) == "1" ]] || (cd kubeadm && ./kubeadm_installer.sh && ./kubeadm_initializer.sh || echo 1 > ../STATUS)
echo e: $(cat STATUS)

[[ $(cat STATUS) == "1" ]] || (cd weavenet && ./weavenet_installer.sh || echo 1 > ../STATUS)
echo f: $(cat STATUS)

# [[ $(cat STATUS) == "1" ]] || (cd calico && ./calico_installer.sh || echo 1 > ../STATUS)
# echo f: $(cat STATUS)

[[ $(cat STATUS) == "1" ]] || (./controlplane_configurer.sh || echo 1 > ../STATUS)
echo g: $(cat STATUS)

[[ $(cat STATUS) == "0" ]] || echo "CLUSTER NOT INITIALIZED!"

rm STATUS