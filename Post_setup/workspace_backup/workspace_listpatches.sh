#!/usr/bin/env bash

if [[ -L $(which wsd) ]]; then
    curDir="$(dirname "$(tracelink wsd)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/../../.systemConfig

wsConfig="$curDir"/config/.wsConfig

process_branch_request() {
    local_repo=${1}
    cur_branch=${2}

    if [[ -z "$ref" || "$ref" = "local" ]]; then
        # For local
        # Find latest commit id
        last_commit_id=$(git log $cur_branch --max-count=1 2> /dev/null | grep commit | cut -d' ' -f2)
        [[ -z $last_commit_id ]] && return

        # Find the path for this commit id and locate .changeTracker
        dest_commit_id="$workspace_backup_local"/"$(hostname)"/"$local_repo"/refLocal/branches/"$cur_branch"/"$last_commit_id"

        if [[ -e "$dest_commit_id"/.changeTracker ]]; then
            echo -e "\nRef: local\tBranch:$cur_branch"
            echo -e "List of available Delta-Id:"
            cat "$dest_commit_id"/.changeTracker | cut -d'-' -f1 | uniq | xargs -I X echo "cat "$dest_commit_id"/.changeTracker | grep X | tail -n1" | bash
        else
            echo -e "\nRef: local\tBranch:$cur_branch"
            echo -e "No backup done till now"
        fi
    fi
    
    if [[ -z "$ref" || "$ref" = "remote" ]]; then
        # For remote
        remote_node=$(git remote show)
        tracked_br=$(git remote show $remote_node | grep "pushes to" | grep $cur_branch | grep -oP '(?<=pushes to\s)\S+')
        head=$remote_node/$tracked_br

        # NOTE: TODO: Check the following logic if it is correct. This is needed when to upstream branch is set to push the changes in the current branch.
        # Hence, the above check doesn't work. We mainly intend "to find the last commit id pushed to any remote branch, and find a diff from that"
        if [[ -z "$tracked_br" ]]; then
            head=$(git show-branch -a | sed "0,/^.*$cur_branch/d" | grep "$remote_node" | head -n1 | sed "s#.*\[\(.*\)\].*#\1#g")
        fi
        last_commit_id_remote=$(git show "$head" 2> /dev/null | grep commit | cut -d' ' -f2)
        [[ -z $last_commit_id_remote ]] && return
        dest_commit_id_remote="$workspace_backup_local"/"$(hostname)"/"$local_repo"/refRemote/branches/"$cur_branch"/"$last_commit_id_remote"

        if [[ -e "$dest_commit_id_remote"/.changeTracker ]]; then
            echo -e "\nRef: remote\tBranch:$cur_branch"
            echo -e "List of available Delta-Id:"
            cat "$dest_commit_id_remote"/.changeTracker | cut -d'-' -f1 | uniq | xargs -I X echo "cat "$dest_commit_id_remote"/.changeTracker | grep X | tail -n1" | bash
        else
            echo -e "\nRef: remote\tBranch:$cur_branch"
            echo -e "No backup done till now"
        fi
    fi

}

process_repo_request() {
    local_repo=${1}
    cur_branch=${2}

    (
        local_ws="$user_devroot"/"$repo_root"/"$local_repo"
        [[ ! -d $local_ws ]] && return

        # Move to local git repo
        cd $local_ws

        [[ -n $cur_branch ]] && process_branch_request "$local_repo" "$cur_branch" && return

        git branch | xargs -I X echo "echo 'X' | tr '*' ' ' | sed 's/^ *//g'" | bash | xargs -I X echo "process_branch_request $local_repo X" | bash
    )

}

processWS() {
    cur_branch=${1}

    for wsPath in $(cat "$wsConfig"); do
        ws=$(basename $wsPath)

        echo -e "\n-----------------------------------------------------------------"
        echo -e "Workspace: $wsPath"
        echo -e "-----------------------------------------------------------------"

        process_repo_request $ws $cur_branch
    done
}

export -f process_branch_request
export workspace_backup_local

allRepo=1
allBranch=1
ref=

for arg in "$@"; do
    case $arg in
    --ws=*)
        sRepo=$(echo $arg | sed "s/--ws=\(.*\)/\1/")
        allRepo=0
        ;;
    --branch=*)
        sBranch=$(echo $arg | sed "s/--branch=\(.*\)/\1/")
        allBranch=0
        ;;
    --refLocal)
        ref='local'
        ;;
    --refRemote)
        ref='remote'
        ;;
    *) ;;
    esac
done

export ref
case "$allRepo""$allBranch" in
11)
    processWS
    ;;
10)
    processWS $sBranch
    ;;
01)
    local_repo=$(cat "$wsConfig" | grep "/$sRepo$" | xargs -I X echo "echo \$(basename X)" | bash)
    process_repo_request $local_repo
    ;;
00)
    local_repo=$(cat "$wsConfig" | grep "/$sRepo$" | xargs -I X echo "echo \$(basename X)" | bash)
    process_repo_request $local_repo $sBranch
    ;;
*) ;;

esac
