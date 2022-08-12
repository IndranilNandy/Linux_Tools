#!/usr/bin/env bash

if [[ -L $(which wsd) ]]; then
    curDir="$(dirname "$(tracelink wsd)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/../../.systemConfig

if_branch_exists() {
    branch=${1}
    git branch | grep " $branch$" > /dev/null
}

reset_and_reset_@commitid() {
    source_wsPath=${1}
    source_branch=${2}
    cid=${3}

    deltaIdList_local="$(pwd)/wsdData/.deltaIDs_local"
    deltaIdList_remote="$(pwd)/wsdData/.deltaIDs_remote"
    status="$(pwd)/wsdData/.status"

    echo -e "\ncommit id = $cid"

    wsd sync --ws="$source_ws" --branch=$source_branch --commit="$cid" --refLocal --short > "$deltaIdList_local"
    echo -e "Local deltaIDs"
    cat "$deltaIdList_local"

    did=$(cat "$deltaIdList_local" | head -n1)
    sed -i "s/\(.*:deltaID:\).*/\1$did/g" $status

    wsd sync --ws="$source_ws" --branch=$source_branch --commit="$cid" --refRemote --short > "$deltaIdList_remote"
    echo -e "Remote deltaIDs"
    cat "$deltaIdList_remote"    

}
restore_ws_from_local() {
    source_wsPath=${1}
    source_branch=${2}

    source_ws=$(basename $source_wsPath)
    echo "ws: $source_ws"
    echo "abc:$workspace_restore_root"
    echo "source: $source_wsPath"
    mkdir -p $workspace_restore_root
    
    sudo cp -r "$source_wsPath" "$workspace_restore_root"/
    ws=$(basename "$source_wsPath")

    (
        restore_ws="$workspace_restore_root"/"$ws"
        cd "$restore_ws"
        if_branch_exists $source_branch || echo "Try a clone from remote repository!"
        mkdir -p "$restore_ws"/wsdData
        pwd
        commitIdList="$(pwd)/wsdData/.commitIDs"
        status="$(pwd)/wsdData/.status"
        echo "commitID:_:deltaID:_" > $status

        git log $source_branch --max-count=10 2> /dev/null | grep commit | cut -d' ' -f2 > "$commitIdList"
        cat "$commitIdList"

        # cid="6c521935c6c87323227f5a3b5de130cd856fe2fe"
        # did=$(wsd sync --ws="$source_ws" --branch=$source_branch --commit="$cid" --refLocal --short)
        # echo -e "cid = $cid\tdid = $did"
        # ls "$workspace_backup_local"/"$(hostname)"/"$source_ws"/refLocal/branches/"$source_branch"/"$cid"/"$did"
        # code .
        cid=$(cat "$commitIdList" | head -n1)
        sed -i "s/\(commitID:\).*\(:deltaID:.*\)/\1$cid\2/g" $status
        reset_and_reset_@commitid $source_ws $source_branch $(cat "$commitIdList" | head -n1)
    )

}
pShort=0
for arg in "$@"; do
    case $arg in
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
    *) ;;
    esac
done

restore_ws_from_local $wsPath $pBranch 