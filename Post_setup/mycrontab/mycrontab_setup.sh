#!/usr/bin/env bash

if [[ -L $(which mycrontab) ]]; then
    curDir="$(dirname "$(tracelink mycrontab)")"
else
    curDir="$(pwd)"
fi

case ${1} in
--config)
    editor -w "$curDir"/.crontab
    "$curDir"/init_crontab.sh
    ;;
--help)
    cat "$curDir"/help/mycrontab.help
    ;;
*)
    cat "$curDir"/help/mycrontab.help
    ;;
esac
