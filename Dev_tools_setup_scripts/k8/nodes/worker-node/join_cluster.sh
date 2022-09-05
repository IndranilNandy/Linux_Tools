#!/usr/bin/env bash

node_c=$(cat ./config/.clusterconfig | grep "controlplane:" | sed "s/controlplane: *\(.*\)/\1/" | tr " *" "\n" | xargs -I X echo X)

! sudo kubeadm join --token $(cat ./credentials/token) "$node_c":6443 --discovery-token-ca-cert-hash sha256:$(cat ./credentials/ca-cert-hash) --cri-socket=unix:///var/run/cri-dockerd.sock && echo -e "[WORKER] FAILED!! Worker node $(hostname) not able to join to the control plane $node_c" && exit 1
rm -rf ./credentials

exit 0
