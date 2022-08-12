#!/usr/bin/env bash

if [[ -L $(which wsd) ]]; then
    curDir="$(dirname "$(tracelink wsd)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/../../.systemConfig

fetchSyncPoints() {
    cur_ws=${1}
    cur_branch=${2}
    cur_CID=${3}
    cur_ref=${4}
    if_short=${5}

    [[ -z $cur_CID ]] && return
    if [[ $cur_ref = "local" ]]; then
        dest_commit_id="$workspace_backup_local"/"$(hostname)"/"$cur_ws"/refLocal/branches/"$cur_branch"/"$cur_CID"
    else
        dest_commit_id="$workspace_backup_local"/"$(hostname)"/"$cur_ws"/refRemote/branches/"$cur_branch"/"$cur_CID"
    fi

    if [[ -e "$dest_commit_id"/.changeTracker ]]; then
        delta_ids=$(cat "$dest_commit_id"/.changeTracker | cut -d'-' -f1 | uniq | xargs -I X echo "cat "$dest_commit_id"/.changeTracker | grep X | tail -n1" | bash | tac)
        [[ "$if_short" = 1 ]] && echo "$delta_ids" | cut -d'-' -f1 && return
        echo "$delta_ids"
    fi
}

# export workspace_backup_local
pShort=0
for arg in "$@"; do
    case $arg in
    --ws=*)
        pWS=$(echo $arg | sed "s/--ws=\(.*\)/\1/")
        ;;
    --branch=*)
        pBranch=$(echo $arg | sed "s/--branch=\(.*\)/\1/")
        ;;
    --commit=*)
        pCID=$(echo $arg | sed "s/--commit=\(.*\)/\1/")
        ;;
    --refLocal)
        pRef='local'
        ;;
    --refRemote)
        pRef='remote'
        ;;
    --short)
        pShort=1
        ;;
    *) ;;
    esac
done

fetchSyncPoints $pWS $pBranch $pCID $pRef $pShort
