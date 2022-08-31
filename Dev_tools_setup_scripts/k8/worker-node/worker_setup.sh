#!/usr/bin/env bash

wnode="${1}"

echo -e "SETUP WILL NOW INITIALIZE WORKER NODES"
echo -e "node: $wnode"

! [[ -d ../k8 ]] && echo -e "[WORKER] FAILED!! Credentials not available from control plane" && exit 1
! scp -r ~/MyTools/Linux_Tools/Dev_tools_setup_scripts/k8 indranilnandy@"$wnode":~ && echo -e "[WORKER] Failed to copy codebase" && exit 1
! ssh -t indranilnandy@"$wnode" "cd ~/k8; bash --login ./k8_cluster_init.sh" --node=worker && echo -e "[WORKER] FAILED!! Setup NOT completed in worker nodes" && exit 1

exit 0
