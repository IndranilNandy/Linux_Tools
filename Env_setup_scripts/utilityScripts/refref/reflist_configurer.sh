#!/usr/bin/env bash

if [[ -z $(which refref) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which refref)")")
fi

config_src="$HOME/.myconfig"
scriptRefsRoot="/usr/local/bin/myscriptrefs"

configloader_src="$config_src"/.configloader
refloader="$configloader_src"/.refloader

create_symlinks() {
    ls -a1 "$refloader" | grep -E -v "\.$|\.\.$" | xargs -I X echo "yes | sudo ln -s -i $refloader/X $scriptRefsRoot/X" | bash
}

help() {
    cat "$curDir"/refref.help
}

create_refs() {
    cat "$curDir"/.refconfig | xargs -I X echo "createref X" | bash
}

(("$#" == 0)) && help && exit 0

case ${1} in
--sym)
    create_symlinks
    ;;
--ref)
    create_refs
    ;;
--sync)
    create_refs
    create_symlinks
    ;;
--help)
    help
    ;;
*)
    help
    ;;
esac
