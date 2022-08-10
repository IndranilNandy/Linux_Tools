#!/usr/bin/env bash

if [[ -L $(which wsd) ]]; then
    curDir="$(dirname "$(tracelink wsd)")"
else
    curDir="$(pwd)"
fi
echo "curDir:$curDir"

commandsDir="$curDir"/commands

case ${1} in
clone)
    "$curDir"/workspace_clone.sh
    ;;
backup)
    "$curDir"/workspace_backup.sh
    ;;
list)
    "$curDir"/workspace_listpatches.sh
    ;;
*)
    echo "--help"
    ;;
esac
# git branch
