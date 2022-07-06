#!/bin/bash

[[ -d ./temp ]] || mkdir ./temp
cd ./temp
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb
cd ..
rm -rf ./temp

# rm ./google-chrome-stable_current_amd64.deb