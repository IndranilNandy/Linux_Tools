#!/usr/bin/env bash

if [[ -z $(which createref) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which createref)")")
fi

config_src="$HOME/.myconfig"
configloader_src="$config_src"/.configloader
refloader="$configloader_src"/.refloader

if [[ "${1}" == "--help" ]]; then
    cat "$curDir"/createref.help
    exit 0
fi

scriptname=${1}
scriptpath=${2}

[[ -e "$refloader"/"$scriptname" ]] && echo -e "Reference already exists" && exit 0

cat << EOF > "$refloader"/"$scriptname"
#!/bin/bash

cd "$scriptpath" && ./$scriptname \$*
EOF

chmod +x "$refloader"/"$scriptname"