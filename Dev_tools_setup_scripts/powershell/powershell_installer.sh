#!/bin/bash

# Ref. https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu?view=powershell-7.3#installation-via-package-repository
# Update the list of packages
sudo apt-get update
# Install pre-requisite packages.
sudo apt-get install -y wget apt-transport-https software-properties-common

# Create temporary placeholder
[[ -d ./temp ]] || mkdir ./temp
cd ./temp

# Download the Microsoft repository GPG keys
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb

# Update the list of packages after we added packages.microsoft.com
sudo apt-get update
# Install PowerShell
sudo apt-get install -y powershell

# Delete temporary directory and files
cd ..
rm -rf ./temp
./packages/libssl_installer.sh

# Start PowerShell
pwsh ./modules/modules_installer.sh