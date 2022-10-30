#!/usr/bin/env bash

node="${1}"

echo -e "\n[TEAR CONTROLPLANE] THIS WILL NOW TEAR DOWN CONTROL PLANE AND DRAIN WORKER NODES: $node"
user=$(cat ./config/.machineconfig | grep -i "$node:" | sed "s/$node: *\(.*\)/\1/I" | tr " *" "\n" | xargs -I X echo X)

. ./lib/loadCred.lib "$user" "$node"



! sshpass -p "$passwd" scp -o 'StrictHostKeyChecking no' -r ~/MyTools/Linux_Tools/Dev_tools_setup_scripts/k8 "$user"@"$node":~ && echo -e "[TEAR CONTROLPLANE] Failed to copy codebase to control plane $node" && exit 1
! sshpass -p "$passwd" ssh -o 'StrictHostKeyChecking no' -t "$user"@"$node" "cd ~/k8; echo $passwd | sudo -S whoami; bash --login ./cluster/k8_cluster_cleanup.sh" && echo -e "[TEAR CONTROLPLANE] FAILED!! Tearing down faced issues in control plane $node" && exit 1

exit 0