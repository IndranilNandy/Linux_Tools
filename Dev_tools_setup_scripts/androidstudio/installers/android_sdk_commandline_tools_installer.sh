#!/usr/bin/env bash

# Ref: https://developer.android.com/studio/command-line/sdkmanager

ANDROID_SDK="$HOME"/Android/Sdk

install_android_sdk_cmd_tools_from_binary() {
    [[ -d "$ANDROID_SDK"/cmdline-tools ]] && echo -e "Since directory \"$ANDROID_SDK/cmdline-tools\" already exists, assuming that the binary is already installed." && return 0

    mkdir tmp
    (
        cd tmp || return

        # Binaries: https://developer.android.com/studio/archive
        wget -O android-cmdtools.zip "https://dl.google.com/android/repository/commandlinetools-linux-9123335_latest.zip"
        mkdir -p "$ANDROID_SDK"/cmdline-tools
        unzip android-cmdtools.zip -d "$ANDROID_SDK"/cmdline-tools
        mv "$ANDROID_SDK"/cmdline-tools/cmdline-tools "$ANDROID_SDK"/cmdline-tools/latest
    )
    rm -rf tmp
}

add_env_var() {
    tools="$ANDROID_SDK"/cmdline-tools/latest
    bin="$ANDROID_SDK"/cmdline-tools/latest/bin
    platformtools="$ANDROID_SDK"/platform-tools
    buildtools="$ANDROID_SDK"/build-tools

    myshpath add --path="$tools:$bin:$platformtools:$buildtools" --export="ANDROID_HOME=$ANDROID_SDK"
}

install_android_sdk_cmd_tools_from_binary && add_env_var