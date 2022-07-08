#!/bin/bash

pattern1='#  AutomaticLoginEnable = true'
replacement1='AutomaticLoginEnable = true'

pattern2='#  AutomaticLogin = user1'
replacement2="AutomaticLogin = $(whoami)"

[ ! -e "/etc/gdm3/custom.conf.bak" ] && sudo cp /etc/gdm3/custom.conf /etc/gdm3/custom.conf.bak

sudo sed -i "s/$pattern1/$replacement1/g" /etc/gdm3/custom.conf
sudo sed -i "s/$pattern2/$replacement2/g" /etc/gdm3/custom.conf

# sudo reboot 