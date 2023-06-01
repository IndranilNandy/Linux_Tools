#!/usr/bin/env bash

# Ref: https://developer.android.com/studio/install

install_required_libraries() {
    yes | sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386
}

install_android_studio_from_binary() {
    [[ -d /opt/android-studio ]] && echo -e "Since directory \"/opt/android-studio\" already exists, assuming that the binary is already installed." && return 0

    mkdir tmp
    (
        cd tmp || return

        # Binaries: https://developer.android.com/studio/archive
        wget -O android-studio.tar.gz "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2022.1.1.19/android-studio-2022.1.1.19-linux.tar.gz"
        sudo tar xvzf android-studio.tar.gz -C /opt
    )
    rm -rf tmp
}

create_symlink() {
    yes | sudo ln -s -i /opt/android-studio/bin/studio.sh "$MYCOMMANDSREPO"/androidstudio

    # Note: This is required because otherwise 'flutter doctor' will flag error - 'Unable to find bundled Java version.'
    # https://github.com/flutter/flutter/issues/118502
    # https://stackoverflow.com/a/75145961/15347692
    yes | sudo ln -s -i /opt/android-studio/jbr /opt/android-studio/jre
}

validate_and_install() {
    desktop-file-validate android-studio.desktop && sudo desktop-file-install android-studio.desktop
}

! ( install_required_libraries && install_android_studio_from_binary && create_symlink && validate_and_install ) && echo -e "Error in installing Android Studio" && exit 1
