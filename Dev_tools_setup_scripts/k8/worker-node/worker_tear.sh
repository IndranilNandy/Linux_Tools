#!/usr/bin/env bash

node="${1}"

echo -e "\n[TEAR WORKER]THIS WILL NOW TEAR DOWN WORKER NODE: $node"

. ./lib/credentials.lib $node
! sshpass -p "$passwd" scp -o 'StrictHostKeyChecking no' -r ~/k8 indranilnandy@"$node":~ && echo -e "[TEAR WORKER] Failed to copy codebase to worker node $node with error code $?" && exit 1
! sshpass -p "$passwd" ssh -o 'StrictHostKeyChecking no' -t indranilnandy@"$node" "cd ~/k8; bash --login ./k8_cluster_cleanup.sh" && echo -e "[TEAR WORKER] FAILED!! Tearing down faced issues in worker node $node" && exit 1

exit 0
