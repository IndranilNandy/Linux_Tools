#!/usr/bin/env bash

configure_with_calico() {
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/tigera-operator.yaml || return 1
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/custom-resources.yaml || return 1
    return 0
}

verify_pod_network() {
    echo -e "Waiting for 3 mins to verify pod network"
    sleep 180
    [[ $(kubectl get pods -n calico-system | grep -v NAME | wc -l) == $(kubectl get pods -n calico-system | grep Running | wc -l) ]] || return 1
    echo -e "Pod network verification done"
}

# https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart
! configure_with_calico && echo -e "[CALICO CONFIGURATION] FAILED!! Configuration with Calico failed" && exit 1
echo -e "[CALICO CONFIGURATION] Run 'watch kubectl get pods -n calico-system' to verify if all the pods are running. It may take some time."

# ! verify_pod_network && echo -e "[CALICO CONFIGURATION] FAILED!! Calico pod network not working. You may increase waiting time for verification"

exit 0
