#!/usr/bin/env bash

node="${1}"

echo -e "\nTHIS WILL NOW TEAR DOWN CONTROL PLANE AND DRAIN WORKER NODES: $node"

. ./lib/credentials.lib ${1}

! sshpass -p "$passwd" scp -o 'StrictHostKeyChecking no' -r ~/MyTools/Linux_Tools/Dev_tools_setup_scripts/k8 indranilnandy@"$node":~ && echo -e "[CONTROLPLANE] Failed to copy codebase" && exit 1
! sshpass -p "$passwd" ssh -o 'StrictHostKeyChecking no' -t indranilnandy@"$node" "cd ~/k8; bash --login ./k8_cluster_cleanup.sh" && echo -e "[CONTROLPLANE] FAILED!! Setup NOT completed in control plane" && exit 1

exit 0