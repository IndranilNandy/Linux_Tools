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
refname=${3}

if [[ -z "$refname" ]]; then
    refname="$scriptname"
fi

create_refs() {
    [[ -e "$refloader"/"$refname" ]] && echo -e "[$refname] Reference already exists" && exit 0

    cat <<EOF >"$refloader"/"$refname"
#!/bin/bash

(cd "$scriptpath" && chmod +x $scriptname && ./$scriptname \$*)
EOF

    chmod +x "$refloader"/"$refname"
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
