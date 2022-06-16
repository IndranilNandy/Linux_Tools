#!/bin/bash

. ./cifs_sharing_commons.lib

if_package_missing $0; 
# echo "if [$? -ne 0] then echo \"One or more packages missing. Exiting...\";exit 1; fi" | bash
if [[ $? -ne 0 ]]
then
    echo "One or more packages missing. Exiting..."
    exit 1
fi

# Create shared folder if it doesn't exist already
(cd $defaultSharedFolder) || (mkdir $defaultSharedFolder && echo "Default shared folder created as $defaultSharedFolder") || (echo "Creation of default shared folder failed..." && exit 1)

# Mount shared folder
mount_cifs_sharing