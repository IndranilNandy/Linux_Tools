#!/usr/bin/env bash


./container_runtime_prereq.sh || exit 1
./cri-dockerd_installer.sh || exit 1