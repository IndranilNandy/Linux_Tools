#!/bin/bash

# https://wiki.winehq.org/Ubuntu

check_architecture() {
    echo "Running check_architecture"
    [ $(dpkg --print-architecture) = "amd64" ] || exit 1
    [ $(dpkg --print-foreign-architectures) = "i386" ] || (yes | sudo dpkg --add-architecture i386)
    [ $(dpkg --print-foreign-architectures) = "i386" ] || exit 1
}

add_winehq_repo() {
    echo "Running add_winehq_repo"
    # wget -nc https://dl.winehq.org/wine-builds/winehq.key
    # sudo mv winehq.key /usr/share/keyrings/winehq-archive.key
    # wget -nc https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
    # sudo mv winehq-jammy.sources /etc/apt/sources.list.d/

    # Commented out the above implementation as it stopped working for jammy release
    sudo mkdir -pm755 /etc/apt/keyrings
    sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
    sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
}

install_wine() {
    echo "Running install_wine"
    # sudo apt update && ( yes | sudo apt install wine )
    sudo apt update && (yes | sudo apt install --install-recommends winehq-stable)
}

verify_installation() {
    echo "Running verify_installation"
    wine --version || (echo "Installation failed" && exit 1)
}

(check_architecture) && (add_winehq_repo) && (install_wine) && (verify_installation)

# Fix misplaced launcher
sudo ln -s /usr/share/doc/wine/examples/wine.desktop /usr/share/applications/
./configurer/wine_configurer.sh
./gecko/gecko_installer.sh
