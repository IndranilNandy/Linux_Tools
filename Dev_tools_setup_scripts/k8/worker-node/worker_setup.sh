#!/usr/bin/env bash

wnode="${1}"

echo -e "\nSETUP WILL NOW INITIALIZE WORKER NODE: $wnode"

. ./lib/credentials.lib "$wnode"

! [[ -d ../k8 ]] && echo -e "[WORKER] FAILED!! Credentials not available from control plane" && exit 1
! sshpass -p "$passwd" scp -o 'StrictHostKeyChecking no' -r ~/MyTools/Linux_Tools/Dev_tools_setup_scripts/k8 indranilnandy@"$wnode":~ && echo -e "[WORKER] Failed to copy codebase to worker node $wnode" && exit 1
! sshpass -p "$passwd" ssh -o 'StrictHostKeyChecking no' -t indranilnandy@"$wnode" "cd ~/k8; bash --login ./k8_cluster_init.sh" --node=worker && echo -e "[WORKER] FAILED!! Setup NOT completed in worker node $wnode" && exit 1

exit 0
