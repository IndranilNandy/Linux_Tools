#!/bin/bash

. ./lib/cifs_sharing_commons.lib
. ./config/config_loader.lib

if_package_missing ".prereq"; 
[[ $? -ne 0 ]] && echo "One or more packages missing. Exiting..." && exit 1
load_config $*

# Create shared folder if it doesn't exist already
[[ ! -d $defaultSharedFolder ]] && (mkdir $defaultSharedFolder && echo "Default shared folder created as $defaultSharedFolder")  

# Mount shared folder
mount_cifs_sharing