#!/usr/bin/env bash

ANDROID_SDK="$HOME"/Android/Sdk

remove_env_vars() {
    envloader="$MYCONFIGLOADER"/.envloader

    androidhome="export ANDROID_HOME=$ANDROID_SDK"

    tools="$ANDROID_SDK"/cmdline-tools/latest
    bin="$ANDROID_SDK"/cmdline-tools/latest/bin
    platformtools="$ANDROID_SDK"/platform-tools
    buildtools="$ANDROID_SDK"/build-tools

    sed -i "\,^$androidhome$,d" "$envloader"

    # DO NOT CHANGE THE ORDER BETWEEN bin AND tools
    sed -i "s@\(.*\):$bin\(.*\)@\1\2@" "$envloader"
    sed -i "s@\(.*\):$tools\(.*\)@\1\2@" "$envloader"
    sed -i "s@\(.*\):$platformtools\(.*\)@\1\2@" "$envloader"
    sed -i "s@\(.*\):$buildtools\(.*\)@\1\2@" "$envloader"
}

remove_android_sdk_home() {
    [[ -d "$HOME"/Android ]] && rm -rf "$HOME"/Android
}

remove_env_vars && remove_android_sdk_home