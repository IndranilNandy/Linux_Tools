#!/usr/bin/env bash


! ./components/container_runtime/container_runtime_prereq.sh && echo -e "[Container Runtime] FAILED!! Prereq check failed" && exit 1
! ./components/container_runtime/cri-dockerd_installer.sh && echo -e "[Container Runtime] FAILED!! cri-dockerd installation failed" && exit 1
exit 0