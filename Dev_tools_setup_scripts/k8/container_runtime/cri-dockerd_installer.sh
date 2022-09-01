#!/usr/bin/env bash

installer() {
    mkdir tmp
    (
        cd tmp

        wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.2.5/cri-dockerd_0.2.5.3-0.ubuntu-jammy_amd64.deb
        sudo dpkg -i cri-dockerd_0.2.5.3-0.ubuntu-jammy_amd64.deb
    )
    rm -rf tmp
}

# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
# https://www.mirantis.com/blog/how-to-install-cri-dockerd-and-migrate-nodes-from-dockershim
# https://github.com/Mirantis/cri-dockerd/releases/tag/v0.2.5

! (which cri-dockerd && echo "cri-dockerd already installed") && ! installer && echo -e "[Container Runtime] FAILED!! cri-dockerd installer failed" && exit 1
exit 0