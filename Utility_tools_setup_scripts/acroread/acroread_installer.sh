#!/usr/bin/env bash

# Download acrobat reader binary
mkdir temp
wget -O ./temp/adobe.deb ftp://ftp.adobe.com/pub/adobe/reader/unix/9.x/9.5.5/enu/AdbeRdr9.5.5-1_i386linux_enu.deb

# Enable i386 architecture
sudo dpkg --add-architecture i386
sudo apt update

# Install all prereq
yes | sudo apt install libxml2:i386 libcanberra-gtk-module:i386 gtk2-engines-murrine:i386 libatk-adaptor:i386 libgdk-pixbuf-xlib-2.0-0:i386

# Install acrobat reader package
sudo dpkg -i ./temp/adobe.deb

# Remove downloaded binary
rm -rf ./temp
