#!/bin/bash

wget http://dl.winehq.org/wine/wine-gecko/2.47.1/wine-gecko-2.47.1-x86_64.msi
wine msiexec /i wine-gecko-2.47.1-x86_64.msi 
rm wine-gecko-2.47.1-x86_64.msi
ls -l "$HOME/.wine/drive_c/windows/system32/gecko/2.47.1/"