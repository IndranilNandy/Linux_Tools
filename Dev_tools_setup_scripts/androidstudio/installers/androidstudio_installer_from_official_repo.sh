#!/usr/bin/env bash

# Ref: https://adamtheautomator.com/android-studio/

add_repo() {
    sudo add-apt-repository ppa:maarten-fonville/android-studio
}

install_android_studio() {
    sudo apt update -y
    sudo apt install android-studio -y
}

( add_repo && install_android_studio ) || echo -e "Error in installing Android Studio"