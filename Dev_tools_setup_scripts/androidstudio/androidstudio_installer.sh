#!/usr/bin/env bash

./installers/androidstudio_installer_from_binary.sh || exit 1
./installers/android_sdk_commandline_tools_installer.sh
./installers/sdkmanager_install_packages.sh
./installers/androidstudio_configurer.sh