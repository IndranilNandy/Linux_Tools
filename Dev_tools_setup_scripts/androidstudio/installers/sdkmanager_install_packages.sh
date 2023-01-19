#!/usr/bin/env bash

# Ref: https://developer.android.com/studio/command-line/sdkmanager#update-all

ANDROID_SDK="$HOME"/Android/Sdk

install_packages() {
    # Note: When you launch the android studio for the first time, it'll download all of these required packages.
    # To see those packages, run 'sdkmanager --list_installed'
    # Here, we are downloading them explicitly, since Flutter installation requires these packages before we manually open android studio for the first time.
    # https://developer.android.com/studio/intro/update#recommended
    packages=('build-tools;33.0.1' 'emulator' 'patcher;v4' 'platform-tools' 'platforms;android-33-ext4')
    for package in "${packages[@]}"; do
        echo "\"$package\""
        yes | "$ANDROID_SDK"/cmdline-tools/latest/bin/sdkmanager --install "$package"
    done
    # "$ANDROID_SDK"/cmdline-tools/latest/bin/sdkmanager --install
}

update_packages() {
    yes | "$ANDROID_SDK"/cmdline-tools/latest/bin/sdkmanager --update
}

accept_licenses() {
    yes | "$ANDROID_SDK"/cmdline-tools/latest/bin/sdkmanager --licenses
}

install_packages && update_packages && accept_licenses
# install_packages