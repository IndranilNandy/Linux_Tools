#!/usr/bin/env bash

if [[ -z $(which createref) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which createref)")")
fi

config_src="$HOME/.myconfig"
configloader_src="$config_src"/.configloader
refloader="$configloader_src"/.refloader

scriptname=${1}
scriptpath=${2}

create_refs() {
    [[ -e "$refloader"/"$scriptname" ]] && echo -e "Reference already exists" && exit 0

    cat <<EOF >"$refloader"/"$scriptname"
#!/bin/bash

(cd "$scriptpath" && chmod +x $scriptname && ./$scriptname \$*)
EOF

    chmod +x "$refloader"/"$scriptname"
}

help() {
    cat "$curDir"/createref.help
}

case ${1} in
--help)
    help
    ;;
'')
    help
    ;;
*)
    create_refs
    ;;
esac
