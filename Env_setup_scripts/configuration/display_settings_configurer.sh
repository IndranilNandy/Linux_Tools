#!/bin/bash
pattern='GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"'
replacement='GRUB_CMDLINE_LINUX_DEFAULT="quiet splash video=hyperv_fb:1920x1080"'

[ ! -e "/etc/default/grub.bak" ] && sudo cp /etc/default/grub /etc/default/grub.bak

sudo sed -i "s/$pattern/$replacement/g" /etc/default/grub
sudo update-grub
# sudo reboot 