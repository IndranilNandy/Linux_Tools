#!/usr/bin/env bash

echo -e "SETUP WILL NOW INITIALIZE CONTROL PLANE"
! scp -r ~/MyTools/Linux_Tools/Dev_tools_setup_scripts/k8 indranilnandy@k8-controlplanenode:~ && echo -e "[CONTROLPLANE] Failed to copy codebase" && exit 1
# ! ssh -t indranilnandy@k8-controlplanenode "cd ~/k8; bash --login ./k8_cluster_init.sh" --node=control --cni=calico && echo -e "[CONTROLPLANE] FAILED!! Setup NOT completed in control plane" && exit 1
! ssh -T indranilnandy@k8-controlplanenode "cd ~/k8; ls -alut" > cred  && echo -e "[CONTROLPLANE] FAILED!! Setup NOT completed in control plane" && exit 1

exit 0