#!/bin/bash

pwsh ./modules/modules_uninstaller.sh
yes | sudo apt-get remove powershell
yes | sudo apt remove libssl1.0.0
yes | sudo apt remove libssl-dev
sudo apt clean
yes | sudo apt autoremove