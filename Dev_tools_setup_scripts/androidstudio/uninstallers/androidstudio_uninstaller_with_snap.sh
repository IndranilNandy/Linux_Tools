#!/usr/bin/env bash

uninstall_android_studio() {
    sudo snap remove android-studio
}

uninstall_android_studio || echo -e "Error while uninstalling Android Studio"