#!/bin/bash
yes | sudo apt install xrdp
sudo systemctl enable --now xrdp
sudo ufw allow from any to any port 3389 proto tcp
#sudo systemctl status xrdp
# sudo ufw allow 3389
# sudo ufw reload
# reboot