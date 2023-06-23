#!/usr/bin/env bash

if [[ -L $(which wsd) ]]; then
    curDir="$(dirname "$(tracelink wsd)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/../../../.systemConfig

if_branch_exists() {
    branch=${1}
    git branch | grep " $branch$" >/dev/null
}

setToPrevDeltaId() {
    gl_rsconfig_loc="$workspace_restore_root"/rsConfig
    openRS="$gl_rsconfig_loc"/.openRestorespaces
    src_wsPath=$(cat $openRS)

    ws=$(basename "$src_wsPath")
    restore_ws="$workspace_restore_root"/"$ws"

    deltaIdList_local="$restore_ws"/rsConfig/.deltaIDs_local
    deltaIdList_remote="$restore_ws"/rsConfig/.deltaIDs_remote
    status="$restore_ws"/rsConfig/.status

    target_commitID=$(sed "s/commitID:\(.*\):deltaID.*/\1/" "$status")
    cur_deltaID=$(sed "s/.*deltaID:\(.*\):branch:.*/\1/" "$status")
    target_branch=$(sed "s/.*:branch:\(.*\)/\1/" "$status")

    local_patch_file_dir="$workspace_backup_local"/"$(hostname)"/"$ws"/refLocal/branches/"$target_branch"/"$target_commitID"/"$target_deltaID"
    remote_patch_file_dir="$workspace_backup_local"/"$(hostname)"/"$ws"/refRemote/branches/"$target_branch"/"$target_commitID"/"$target_deltaID"
    local_patch_file=$(ls -1 "$local_patch_file_dir" | grep -E *.patch | grep -E -v windows)
    changeTrackerFile="$workspace_backup_local"/"$(hostname)"/"$ws"/refLocal/branches/"$target_branch"/"$target_commitID"/".changeTracker"
    deltaID_list=$(cat "$changeTrackerFile")
    cat "$changeTrackerFile" | sed "0,/$cur_deltaID/d"
    cat $changeTrackerFile

    wsd sync --ws=$src_wsPath --branch=$target_branch --commit=$target_commitID --refLocal
}

applyPatch() {
    source_wsPath=${1}

    ws=$(basename "$source_wsPath")
    restore_ws="$workspace_restore_root"/"$ws"

    deltaIdList_local="$restore_ws"/rsConfig/.deltaIDs_local
    deltaIdList_remote="$restore_ws"/rsConfig/.deltaIDs_remote
    status="$restore_ws"/rsConfig/.status

    target_commitID=$(sed "s/commitID:\(.*\):deltaID.*/\1/" "$status")
    target_deltaID=$(sed "s/.*deltaID:\(.*\):branch:.*/\1/" "$status")
    target_branch=$(sed "s/.*:branch:\(.*\)/\1/" "$status")

    local_patch_file_dir="$workspace_backup_local"/"$(hostname)"/"$ws"/refLocal/branches/"$target_branch"/"$target_commitID"/"$target_deltaID"
    remote_patch_file_dir="$workspace_backup_local"/"$(hostname)"/"$ws"/refRemote/branches/"$target_branch"/"$target_commitID"/"$target_deltaID"
    local_patch_file=$(ls -1 "$local_patch_file_dir" | grep -E *.patch | grep -E -v windows)
    echo "$local_patch_file"

    (
        cd "$restore_ws"
        echo $PWD | grep -q "$workspace_restore_root" || return
        echo $PWD
        git reset --hard "$target_commitID"
        git apply < "$local_patch_file_dir"/"$local_patch_file"

    )
}

update_status_@commitid() {
    source_wsPath=${1}
    # ws=${1}
    source_branch=${2}
    cid=${3}

    ws=$(basename "$source_wsPath")
    restore_ws="$workspace_restore_root"/"$ws"

    deltaIdList_local="$restore_ws"/rsConfig/.deltaIDs_local
    deltaIdList_remote="$restore_ws"/rsConfig/.deltaIDs_remote
    status="$restore_ws"/rsConfig/.status

    echo -e "\ncommit id = $cid"

    wsd sync --ws="$ws" --branch=$source_branch --commit="$cid" --refLocal --short >"$deltaIdList_local"
    echo -e "Local deltaIDs"
    cat "$deltaIdList_local"

    did=$(cat "$deltaIdList_local" | head -n1)
    sed -i "s/\(.*:deltaID:\).*\(:branch:.*\)/\1$did\2/g" $status

    wsd sync --ws="$ws" --branch=$source_branch --commit="$cid" --refRemote --short >"$deltaIdList_remote"
    echo -e "Remote deltaIDs"
    cat "$deltaIdList_remote"

}
restore_ws_from_local() {
    source_wsPath=${1}
    source_branch=${2}

    echo "abc:$workspace_restore_root"
    echo "source: $source_wsPath"
    echo "restore: $workspace_restore_root"
    mkdir -p $workspace_restore_root

    # sudo cp -r "$source_wsPath" "$workspace_restore_root"/
    cp -r "$source_wsPath" "$workspace_restore_root"/

    ws=$(basename "$source_wsPath")
    echo "source: $source_wsPath"

    restore_ws="$workspace_restore_root"/"$ws"
    commitIdList="$restore_ws"/rsConfig/.commitIDs
    (
        cd "$restore_ws"
        git branch
        if_branch_exists $source_branch || echo "Try a clone from remote repository!"
        mkdir -p "$restore_ws"/rsConfig
        pwd
        commitIdList="$(pwd)/rsConfig/.commitIDs"

        git log $source_branch --max-count=10 2>/dev/null | grep commit | cut -d' ' -f2 >"$commitIdList"
    )
    cat "$commitIdList"

    status="$restore_ws"/rsConfig/.status
    echo "commitID:_:deltaID:_:branch:_" >$status

    cid=$(cat "$commitIdList" | head -n1)
    sed -i "s/\(commitID:\).*\(:deltaID:.*:branch:\)\(.*\)/\1$cid\2$source_branch/g" $status
    update_status_@commitid $source_wsPath $source_branch $(cat "$commitIdList" | head -n1)

    gl_rsconfig_loc="$workspace_restore_root"/rsConfig
    mkdir -p "$gl_rsconfig_loc"

    openRS="$gl_rsconfig_loc"/.openRestorespaces
    [[ -e $openRS ]] || touch $openRS
    echo "source here: $source_wsPath"
    grep -q $source_wsPath $openRS || echo "$source_wsPath" >>$openRS

    code -n "$restore_ws"
    applyPatch $source_wsPath
}
pShort=0
for arg in "$@"; do
    case $arg in
    # restore)
    #     restore_ws_from_local $wsPath $pBranch
    # ;;
    --ws=*)
        pWS=$(echo $arg | sed "s/--ws=\(.*\)/\1/")
        ;;
    --wsPath=*)
        wsPath=$(echo $arg | sed "s/--wsPath=\(.*\)/\1/")
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
    --d+)
        echo "here d+: $arg"
        ;;
    --d-)
        echo "here d+: $arg"
        setToPrevDeltaId
        ;;
    --c+)
        echo "here d+: $arg"
        ;;
    --c-)
        echo "here d+: $arg"
        ;;
    esac
done

# restore_ws_from_local $wsPath $pBranch
