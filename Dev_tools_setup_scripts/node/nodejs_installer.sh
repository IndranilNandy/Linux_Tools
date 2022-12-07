#!/usr/bin/env bash

# https://nodejs.org/en/download/package-manager/#n
# https://phoenixnap.com/kb/update-node-js-version
yes | sudo apt install npm
sudo npm install -g n
sudo n lts
