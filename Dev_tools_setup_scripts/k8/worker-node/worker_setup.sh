#!/usr/bin/env bash

echo -e "SETUP WILL NOW INITIALIZE WORKER NODES"

! [[ -d ../k8 ]] && echo -e "[WORKER] FAILED!! Credentials not available from control plane" && exit 1
! scp -r ~/MyTools/Linux_Tools/Dev_tools_setup_scripts/k8 indranilnandy@k8-worker1:~ && echo -e "[WORKER] Failed to copy codebase" && exit 1
! ssh -t indranilnandy@k8-worker1 "cd ~/k8; bash --login ./k8_cluster_init.sh" --node=worker && echo -e "[WORKER] FAILED!! Setup NOT completed in worker nodes" && exit 1
exit 0