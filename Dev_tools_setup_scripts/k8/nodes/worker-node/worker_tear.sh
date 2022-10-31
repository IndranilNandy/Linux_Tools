#!/usr/bin/env bash

node="${1}"

echo -e "\n[TEAR WORKER] THIS WILL NOW TEAR DOWN WORKER NODE: $node"
user=$(cat ./config/.machineconfig | grep -i "$node:" | sed "s/$node: *\(.*\)/\1/I" | tr " *" "\n" | xargs -I X echo X)

. ./lib/loadCred.lib "$user" "$node"

! sshpass -p "$passwd" scp -o 'StrictHostKeyChecking no' -r ~/k8 "$user"@"$node":~ && echo -e "[TEAR WORKER] Failed to copy codebase to worker node $node with error code $?" && exit 1
! sshpass -p "$passwd" ssh -o 'StrictHostKeyChecking no' -t "$user"@"$node" "cd ~/k8; export psdsource=$psdsource; export k8_tear_allnodes=$k8_tear_allnodes; echo $passwd | sudo -S echo "entered"; bash --login ./cluster/k8_cluster_cleanup.sh" && echo -e "[TEAR WORKER] FAILED!! Tearing down faced issues in worker node $node" && exit 1

exit 0
