#!/bin/bash

. ./lib/cifs_sharing_commons.lib
. ./config/config_loader.lib

if_package_missing ".prereq"; 
# if [[ $? -ne 0 ]]
# then
#     echo "One or more packages missing. Exiting..."
#     exit 1
# fi

[[ $? -ne 0 ]] && echo "One or more packages missing. Exiting..." && exit 1


# if [[ $# -eq 0 ]]; then
#     pcname="DESKTOP-F3I6O06"
#     sharedFolderInWindows="Shared_with_VMs"
#     winuser="indranil nandy"
#     defaultSharedFolder="$HOME/SharedFromWindows"
#     echo "default"
# fi

load_config $*



# Create shared folder if it doesn't exist already
[[ ! -d $defaultSharedFolder ]] && (mkdir $defaultSharedFolder && echo "Default shared folder created as $defaultSharedFolder")  

# Mount shared folder
mount_cifs_sharing