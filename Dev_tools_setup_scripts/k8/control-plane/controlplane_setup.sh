#!/usr/bin/env bash


cnode="${1}"

echo -e "\nSETUP WILL NOW INITIALIZE CONTROL PLANE: $cnode"

. ./lib/credentials.lib ${1}

! sshpass -p "$passwd" scp -o 'StrictHostKeyChecking no' -r ~/MyTools/Linux_Tools/Dev_tools_setup_scripts/k8 indranilnandy@"$cnode":~ && echo -e "[CONTROLPLANE] Failed to copy codebase" && exit 1
! sshpass -p "$passwd" ssh -o 'StrictHostKeyChecking no' -t indranilnandy@"$cnode" "cd ~/k8; bash --login ./k8_cluster_init.sh" --node=control --cni=calico && echo -e "[CONTROLPLANE] FAILED!! Setup NOT completed in control plane" && exit 1

echo -e "[CONTROLPLANE] Setup completed in control plane. Now fetching token and ca-cert-hash"
mkdir ./credentials
! sshpass -p "$passwd" ssh -o 'StrictHostKeyChecking no' -T indranilnandy@"$cnode" "kubeadm token list | cut -f1 -d' ' | tail -n1" >./credentials/token && echo -e "[CONTROLPLANE] FAILED!! Missing token, probable expired, you need to recreate. Use command 'kubeadm token create'" && exit 1
! sshpass -p "$passwd" ssh -o 'StrictHostKeyChecking no' -T indranilnandy@"$cnode" "openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'" >./credentials/ca-cert-hash && echo -e "[CONTROLPLANE] FAILED!! ca-cert-hash NOT available" && exit 1

exit 0
