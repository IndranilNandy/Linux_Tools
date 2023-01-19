#!/usr/bin/env bash

# Ref: https://adamtheautomator.com/android-studio/

install_android_studio() {
    sudo snap install android-studio --classic
}

install_android_studio || echo -e "Error in installing Android studio"