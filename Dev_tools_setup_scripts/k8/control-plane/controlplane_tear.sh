#!/usr/bin/env bash

node="${1}"

echo -e "\n[TEAR CONTROLPLANE] THIS WILL NOW TEAR DOWN CONTROL PLANE AND DRAIN WORKER NODES: $node"

. ./lib/credentials.lib ${1}

! sshpass -p "$passwd" scp -o 'StrictHostKeyChecking no' -r ~/MyTools/Linux_Tools/Dev_tools_setup_scripts/k8 indranilnandy@"$node":~ && echo -e "[TEAR CONTROLPLANE] Failed to copy codebase to control plane $node" && exit 1
! sshpass -p "$passwd" ssh -o 'StrictHostKeyChecking no' -t indranilnandy@"$node" "cd ~/k8; bash --login ./k8_cluster_cleanup.sh" && echo -e "[TEAR CONTROLPLANE] FAILED!! Tearing down faced issues in control plane $node" && exit 1

exit 0