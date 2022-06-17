#!/bin/bash

packageName="gcmcore-linux_amd64.2.0.696.deb"
latestDownloadLink="https://github.com/GitCredentialManager/git-credential-manager/releases/download/v2.0.696/$packageName"
wget $latestDownloadLink
sudo dpkg -i "./$packageName"
rm "./$packageName"

./configurer/gcm_configurer.sh

