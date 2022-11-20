#!/usr/bin/env bash

if [[ -L $(which ws) ]]; then
    curDir="$(dirname "$(tracelink ws)")"
else
    curDir="$(pwd)"
fi

# commandsDir="$curDir"/commands

case ${1} in
--config)
    editor -w "$curDir"/config/.allRepoConfig
    ;;
--clone)
    "$curDir"/workspace_clone.sh "$@"
    ;;
# backup)
#     "$curDir"/workspace_backup.sh "$@"
#     ;;
# list)
#     "$curDir"/workspace_listpatches.sh "$@"
#     ;;
# restore)
#     "$curDir"/workspace_restore.sh "$@"
#     ;;
# sync)
#     "$curDir"/workspace_syncpoints.sh "$@"
#     ;;
# restore)
#     "$curDir"/workspace_restore.sh "$@"
#     ;;
--help)
    cat "$curDir"/help/ws.help
    ;;
*)
    cat "$curDir"/help/ws.help
    ;;
esac
