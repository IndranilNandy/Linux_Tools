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
    ret_code=$("$ANDROID_SDK"/emulator/emulator -accel-check 2> /dev/null | sed -n '/accel:/,+1p' | sed -n '2p')
    (( ret_code == 0 ))&& echo -e "Hardware acceleration already ENABLED!!" && return 0
    (( ret_code == 11 )) && add_kvm_perm_for_user && return 0
    return 1
}

enable_hw_acceleration || echo -e "Failed to enable Hardware Acceleration. Check it manually"