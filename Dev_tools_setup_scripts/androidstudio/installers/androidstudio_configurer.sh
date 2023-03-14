#!/usr/bin/env bash

# NOTE: DO NOT FORGET to enable nested virtualization for the Hyper-v VM before running this script. Use the following command from the host window powershell with administrator rights
# Set-VMProcessor -VMName <VMName> -ExposeVirtualizationExtensions $true
# Ref. https://onedrive.live.com/redir?resid=36449486C8B7B4ED%211154&page=Edit&wd=target%28Topic%20List%202.one%7Cc0608669-f18d-43e8-8d9a-f3e92cdeea58%2FEmulator%20setup%20issues%20in%20VM%7C1fdabc42-13ad-412d-ab83-f420eb893738%2F%29&wdorigin=703
# Ref. https://stackoverflow.com/a/44810051/15347692

ANDROID_SDK="$HOME"/Android/Sdk

add_kvm_perm_for_user() {
    echo -e "Adding KVM permission to $USER"
    sudo gpasswd -a "$USER" kvm
    echo -e "YOU NEED TO RESTART YOUR SYSTEM for KVM permission changes to take effect!!!"
}

enable_hw_acceleration() {
    ret_code=$("$ANDROID_SDK"/emulator/emulator -accel-check 2>/dev/null | sed -n '/accel:/,+1p' | sed -n '2p')
    ((ret_code == 0)) && echo -e "Hardware acceleration already ENABLED!!" && return 0
    ((ret_code == 11)) && add_kvm_perm_for_user && return 0
    return 1
}

get_field_at() {
    local avd="${1}"
    local field="${2}"
    echo "$avd" | gawk -v f="$field" '{print $f}'
}

install_pkg() {
    echo "Installing ${1}"
    yes | "$ANDROID_SDK"/cmdline-tools/latest/bin/sdkmanager --install "${1}"
}

# Ref.  https://developer.android.com/studio/command-line/avdmanager
createAVD() {
    local name="${1}"
    local device="${2}"
    local sysimage="${3}"
    local skin="${4}"

    echo -e "Creating AVD\nname: $name \ndevice:$device \nsysimage:$sysimage \nskin:$skin\n"
    install_pkg "$sysimage"
}

# avdmanager list avd
# avdmanager list target
# avdmanager list device
# sdkmanager --list_installed
# sdkmanager --list
# avdmanager create --help
# avdmanager create avd -n testWithDevice -d 5 -k "system-images;android-30;google_apis_playstore;x86"
create_emulator() {
    export -f get_field_at
    export -f createAVD
    export -f install_pkg
    export ANDROID_SDK

    cat ./installers/.avdlist | grep -v " *#" | xargs -I X echo "createAVD \$(get_field_at \"X\" 1) \
                                        \$(get_field_at \"X\" 2) \
                                        \$(get_field_at \"X\" 3) \
                                        \$(get_field_at \"X\" 4)"| bash
}

enable_hw_acceleration || echo -e "Failed to enable Hardware Acceleration. Check it manually"
create_emulator