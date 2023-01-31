#!/bin/bash

# https://github.com/GitCredentialManager/git-credential-manager/blob/release/docs/install.md#linux
# https://github.com/GitCredentialManager/git-credential-manager/blob/release/docs/credstores.md#gpgpass-compatible-files

fetch_n_install_gcm() {
    # packageName="gcmcore-linux_amd64.2.0.696.deb"
    packageName="gcm-linux_amd64.2.0.785.deb"
    # latestDownloadLink="https://github.com/GitCredentialManager/git-credential-manager/releases/download/v2.0.696/$packageName"
    latestDownloadLink="https://github.com/GitCredentialManager/git-credential-manager/releases/download/v2.0.785/$packageName"
    wget $latestDownloadLink
    sudo dpkg -i "./$packageName"
    rm "./$packageName"
}

fetch_n_install_gcm
./configurer/gcm_configurer.sh