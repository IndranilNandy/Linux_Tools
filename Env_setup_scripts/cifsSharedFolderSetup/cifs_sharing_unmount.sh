#!/bin/bash

if [[ -z $(which cumount) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which cumount)")")
fi

(( "$#" == 1 )) && [[ "$1" == "--help" ]] && cat $curDir/help/cumount.help && exit 0

. $curDir/lib/cifs_sharing_commons.lib
. $curDir/config/config_loader.lib

load_config $*

# Unmount shared folder
unmount_cifs_sharing