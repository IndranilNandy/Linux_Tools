#!/bin/bash

[[ -d ./temp ]] || mkdir ./temp
cd ./temp

wget -q http://security.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5.10_amd64.deb
sudo dpkg -i libssl1.0.0_1.0.2n-1ubuntu5.10_amd64.deb
cd ..
rm -rf ./temp

# Update the list of packages after we added packages.microsoft.com
sudo apt-get update
# Install PowerShell
sudo apt-get install -y libssl-dev
# Start PowerShell