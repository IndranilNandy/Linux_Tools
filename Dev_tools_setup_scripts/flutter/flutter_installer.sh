#!/usr/bin/env bash

# Ref: https://docs.flutter.dev/get-started/install/linux

check_req_tools() {
    req_tools=("bash" "curl" "file" "git" "mkdir" "rm" "unzip" "which" "xz-utils")

    for tool in "${req_tools[@]}"; do
        echo "$tool>"
        ifinstalled "$tool" || return 1
    done
    return 0
}

install_flutter() {
    sudo snap install flutter --classic
}

flutter_config() {
    flutter config --android-sdk "$ANDROID_HOME"
}

flutter_doctor() {
    flutter doctor
    (flutter doctor | grep -q "Doctor found issues") && return 1
    return 0
}

check_req_tools && install_flutter
# flutter_config
flutter_doctor || echo -e "Error while running 'flutter doctor'"
./flutter_upgrade.sh
./dart/dart_env_configurer.sh