#!/bin/bash

yes | sudo apt remove adobereader-enu libxml2:i386 libcanberra-gtk-module:i386 gtk2-engines-murrine:i386 libatk-adaptor:i386 libgdk-pixbuf-xlib-2.0-0:i386
sudo apt clean
yes | sudo apt autoremove
