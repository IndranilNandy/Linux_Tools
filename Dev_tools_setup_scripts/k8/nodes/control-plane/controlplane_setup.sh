#!/usr/bin/env bash


cnode="${1}"

echo -e "\nSETUP WILL NOW INITIALIZE CONTROL PLANE: $cnode"
user=$(cat ./config/.machineconfig | grep -i "$cnode:" | sed "s/$cnode: *\(.*\)/\1/I" | tr " *" "\n" | xargs -I X echo X)

. ./lib/loadCred.lib "$user" "$cnode"

! sshpass -p "$passwd" scp -o 'StrictHostKeyChecking no' -r ~/MyTools/Linux_Tools/Dev_tools_setup_scripts/k8 "$user"@"$cnode":~ && echo -e "[CONTROLPLANE] Failed to copy codebase to control plane $cnode" && exit 1
! sshpass -p "$passwd" ssh -o 'StrictHostKeyChecking no' -t "$user"@"$cnode" "cd ~/k8; bash --login ./cluster/k8_cluster_init.sh" --node=control --cni=calico && echo -e "[CONTROLPLANE] FAILED!! Setup NOT completed in control plane $cnode" && exit 1

echo -e "[CONTROLPLANE] Setup completed in control plane. Now fetching token and ca-cert-hash"
mkdir ./credentials
! sshpass -p "$passwd" ssh -o 'StrictHostKeyChecking no' -T "$user"@"$cnode" "kubeadm token list | cut -f1 -d' ' | tail -n1" >./credentials/token && echo -e "[CONTROLPLANE] FAILED!! Missing token, probable expired on $cnode, you need to recreate. Use command 'kubeadm token create'" && exit 1
! sshpass -p "$passwd" ssh -o 'StrictHostKeyChecking no' -T "$user"@"$cnode" "openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'" >./credentials/ca-cert-hash && echo -e "[CONTROLPLANE] FAILED!! ca-cert-hash NOT available on $cnode" && exit 1

exit 0
