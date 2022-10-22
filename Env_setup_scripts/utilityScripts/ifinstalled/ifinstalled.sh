#!/bin/bash

if [[ -z $(which ifinstalled) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which ifinstalled)")")
fi

case ${1} in
    --list)
        echo "Tools installed with APT package manager:"
        sudo apt list --installed
        echo -e "\nCustom symbolic links available:"
        sudo ls $MYCOMMANDSREPO
        ;;
    --apt)
        echo "Tools installed with APT package manager:"
        sudo apt list --installed
        ;;
    --snap)
        echo "Tools installed with SNAP package manager:"
        sudo snap list
        ;;
    --link)
        echo -e "\nCustom symbolic links available:"
        sudo ls $MYCOMMANDSREPO
        ;;
    --help)
        cat $curDir/ifinstalled.help
        ;;
    "")
        cat $curDir/ifinstalled.help
        ;;
    *)
        which ${1} || (sudo apt list --installed 2> /dev/null | grep ${1}) || (sudo snap list 2> /dev/null | grep ${1})
        ;;
esac