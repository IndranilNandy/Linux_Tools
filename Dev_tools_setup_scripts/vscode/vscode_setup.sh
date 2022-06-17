#!/bin/bash

# Repository and key installed manually
installRepoKey() {
    sudo apt-get install wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
}

# Update the package cache and install the package
installPackage() {
    sudo apt install apt-transport-https
    sudo apt update
    sudo apt install code # or code-insiders
}

# If Visual Studio Code doesn't show up as an alternative to editor, you need to register it
registerEditor() {
    sudo update-alternatives --install /usr/bin/editor editor $(which code) 10
}

# Set as default editor
setAsDefaultEditor() {
    sudo update-alternatives --set editor /usr/bin/code
}

(installRepoKey) && (installPackage) && (registerEditor) && (setAsDefaultEditor)

