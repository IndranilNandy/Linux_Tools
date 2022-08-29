#!/usr/bin/env bash

# https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/configure-cgroup-driver/#configuring-the-kubelet-cgroup-driver
configure_kubelet_cgroup_driver() {
    # TODO
    # In v1.22, if the user is not setting the cgroupDriver field under KubeletConfiguration, kubeadm will default it to systemd. So, no need to configure.
    return 0
}

configure_kubelet_cgroup_driver || exit 1