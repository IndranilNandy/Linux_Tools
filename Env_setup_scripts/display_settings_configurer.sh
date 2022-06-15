#!/bin/bash
pattern='GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"'
replacement='GRUB_CMDLINE_LINUX_DEFAULT="quiet splash video=hyperv_fb:1920x1080"'
sudo sed -i "s/$pattern/$replacement/g" /etc/default/grub
sudo update-grub
sudo reboot 
# echo $pattern $replacement