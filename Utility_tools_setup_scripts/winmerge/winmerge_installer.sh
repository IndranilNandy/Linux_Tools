#!/bin/bash

[[ -d ./temp ]] || mkdir ./temp;
cd ./temp
wget https://github.com/WinMerge/winmerge/releases/download/v2.16.20/WinMerge-2.16.20-x64-Setup.exe
wine WinMerge-2.16.20-x64-Setup.exe
cd ..
rm -rf ./temp