#!/usr/bin/env bash

if [[ -L $(which wsd) ]]; then
    curDir="$(dirname "$(tracelink wsd)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/../../.systemConfig

process_branch_request() {
    remote_repo=${1}
    cur_branch=${2}

    echo -e "Current branch: $cur_branch"
    echo -e "List of available patches:"

    # Find latest commit id
    last_commit_id=$(git log $cur_branch --max-count=1 | grep commit | cut -d' ' -f2)

    # Find the path for this commit id and locate .changeTracker
    dest_commit_id="$workspace_backup_local"/"$(hostname)"/"$remote_repo"/branches/"$cur_branch"/"$last_commit_id"

    [[ ! -e "$dest_commit_id"/.changeTracker ]] && echo -e "No backup done till now" && exit 0
    cat "$dest_commit_id"/.changeTracker | cut -d'-' -f1 | uniq | xargs -I X echo "cat "$dest_commit_id"/.changeTracker | grep X | tail -n1" | bash

}

process_repo_request() {
    remote_repo=${1}
    local_repo=${2}
    cur_branch=${3}

    (
        # Move to local git repo
        cd "$user_devroot"/"$repo_root"/"$local_repo"
        [[ -n $cur_branch ]] && process_branch_request "$remote_repo" "$cur_branch" && exit 0

        # process_branch_request $remote_repo $cur_branch
        git branch | xargs -I X echo "echo 'X' | tr '*' ' ' | sed 's/^ *//g'" | bash | xargs -I X echo "process_branch_request $remote_repo X" | bash
    )

}

repoConfig="$curDir"/config/.allRepoConfig

process_all_repo() {
    cur_branch=${1}

    for x in $(cat "$repoConfig"); do
        repo=$(echo "$x" | sed 's/\(.*\)#.*#.*/\1/')
        remote_repo=$(echo "$repo" | sed "s/.*\/$repo_username\/\(.*\)\.git/\1/")

        local_repo=$(echo "$x" | sed 's/.*#.*#\(.*\)/\1/')

        echo -e "\nRepo: $repo\nWorkspace: $user_devroot/$repo_root/$local_repo\n"
        process_repo_request $remote_repo $local_repo $cur_branch

    done
}

export -f process_branch_request
export workspace_backup_local

allRepo=1
allBranch=1
ref=

for arg in "$@"; do
    case $arg in
    --repo=*)
        sRepo=$(echo $arg | sed "s/--repo=\(.*\)/\1/")
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

case "$allRepo""$allBranch" in
11)
    process_all_repo
    ;;
10)
    process_all_repo $sBranch
    ;;
01)
    remote_repo=$(cat "$repoConfig" | grep $sRepo | sed "s/.*\/$repo_username\/\(.*\)\.git.*/\1/")
    local_repo=$(cat "$repoConfig" | grep $sRepo | sed 's/.*#.*#\(.*\)/\1/')

    process_repo_request $remote_repo $local_repo
    ;;
00)
    remote_repo=$(cat "$repoConfig" | grep $sRepo | sed "s/.*\/$repo_username\/\(.*\)\.git.*/\1/")
    local_repo=$(cat "$repoConfig" | grep $sRepo | sed 's/.*#.*#\(.*\)/\1/')

    process_repo_request $remote_repo $local_repo $sBranch
    ;;
*) ;;

esac
