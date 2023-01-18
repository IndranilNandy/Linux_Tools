#!/usr/bin/env bash

uninstall() {
    sudo rm -rf /opt/android-studio
    sudo rm "$MYCOMMANDSREPO"/androidstudio
}

uninstall || echo -e "Error in uninstalling Android Studio"