#!/usr/bin/env bash

! sudo kubeadm join --token $(cat ./credentials/token) k8-controlplanenode:6443 --discovery-token-ca-cert-hash sha256:$(cat ./credentials/ca-cert-hash) --cri-socket=unix:///var/run/cri-dockerd.sock && echo -e "[WORKER] FAILED!! Not able to join to the control plane" && exit 1
rm -rf ./credentials

exit 0
