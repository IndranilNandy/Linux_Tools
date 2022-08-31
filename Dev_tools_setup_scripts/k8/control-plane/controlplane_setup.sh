#!/usr/bin/env bash

echo -e "SETUP WILL NOW INITIALIZE CONTROL PLANE"
! scp -r ~/MyTools/Linux_Tools/Dev_tools_setup_scripts/k8 indranilnandy@k8-controlplanenode:~ && echo -e "[CONTROLPLANE] Failed to copy codebase" && exit 1
! ssh -t indranilnandy@k8-controlplanenode "cd ~/k8; bash --login ./k8_cluster_init.sh" --node=control --cni=calico && echo -e "[CONTROLPLANE] FAILED!! Setup NOT completed in control plane" && exit 1

echo -e "[CONTROLPLANE] Setup completed in control plane. Now fetching token and ca-cert-hash"
mkdir ./credentials
! ssh -T indranilnandy@k8-controlplanenode "kubeadm token list | cut -f1 -d' ' | tail -n1" >./credentials/token && echo -e "[CONTROLPLANE] FAILED!! Missing token, probable expired, you need to recreate. Use command 'kubeadm token create'" && exit 1
! ssh -T indranilnandy@k8-controlplanenode "openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'" >./credentials/ca-cert-hash && echo -e "[CONTROLPLANE] FAILED!! ca-cert-hash NOT available" && exit 1

exit 0
