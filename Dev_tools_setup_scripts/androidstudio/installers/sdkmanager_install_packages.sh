#!/usr/bin/env bash

# Ref: https://developer.android.com/studio/command-line/sdkmanager#update-all

ANDROID_SDK="$HOME"/Android/Sdk

install_pkg() {
    echo "Installing ${1}"
    yes | "$ANDROID_SDK"/cmdline-tools/latest/bin/sdkmanager --install "${1}"
}

install_packages() {
    # Note: When you launch the android studio for the first time, it'll download all of these required packages.
    # To see those packages, run 'sdkmanager --list_installed'
    # Here, we are downloading them explicitly, since Flutter installation requires these packages before we manually open android studio for the first time.
    # https://developer.android.com/studio/intro/update#recommended
    export -f install_pkg
    export ANDROID_SDK
    cat ./installers/.packagelist | grep -v " *#" | xargs -I X echo "install_pkg \"X\"" | bash
}

install_sys_img() {
    echo "Installing ${1}"
    yes | "$ANDROID_SDK"/cmdline-tools/latest/bin/sdkmanager --install "${1}"
}

install_system_images() {
    # Note: Downloading Android AVD system images. We'll need these later for Flutter development
    # Ref. https://stackoverflow.com/questions/56090813/i-can-get-any-emulators-running-in-vs-code
    export -f install_sys_img
    export ANDROID_SDK
    cat ./installers/.sysimagelist | grep -v " *#" | xargs -I X echo "install_sys_img \"X\"" | bash
}

update_packages() {
    yes | "$ANDROID_SDK"/cmdline-tools/latest/bin/sdkmanager --update
}

accept_licenses() {
    yes | "$ANDROID_SDK"/cmdline-tools/latest/bin/sdkmanager --licenses
}

# install_packages && install_system_images && update_packages && accept_licenses
install_packages
install_system_images
update_packages
accept_licenses