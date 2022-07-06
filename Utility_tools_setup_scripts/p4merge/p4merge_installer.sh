#!/bin/bash

[[ -d ./temp ]] || mkdir ./temp
cd ./temp
wget https://cdist2.perforce.com/perforce/r22.1/bin.linux26x86_64/p4v.tgz
tar zxvf p4v.tgz
sudo mkdir /opt/p4v
cd p4v-*
sudo mv * /opt/p4v
sudo ln -s /opt/p4v/bin/p4merge /usr/local/bin/p4merge
cd ../..
rm -rf ./temp
