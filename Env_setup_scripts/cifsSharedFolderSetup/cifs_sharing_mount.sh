#!/bin/bash

if [[ -z $(which cmount) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which cmount)")")
fi

(( "$#" == 1 )) && [[ "$1" == "--help" ]] && cat $curDir/help/cmount.help && exit 0

. $curDir/lib/cifs_sharing_commons.lib
. $curDir/config/config_loader.lib

load_config $*

[[ ! -d $defaultSharedFolder ]] && (mkdir $defaultSharedFolder && echo "Default shared folder created as $defaultSharedFolder")  
# Mount shared folder
mount_cifs_sharing