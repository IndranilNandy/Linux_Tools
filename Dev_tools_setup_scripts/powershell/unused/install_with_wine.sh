#!/bin/bash

[[ -d ./temp ]] || mkdir ./temp
cd ./temp
# wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.4/PowerShell-7.2.4-win-x64.msi
wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.4/PowerShell-7.2.4-win-x86.msi

wine msiexec /i PowerShell-7.2.4-win-x86.msi
cd ..
rm -rf ./temp
# rm WinMerge-2.16.20-x64-Setup.exe
if [ -d "abc.txt"]; then
    echo "test"
fi
