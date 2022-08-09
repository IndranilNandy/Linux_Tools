#!/usr/bin/env bash

if [[ -L $(which wsd) ]]; then
    curDir="$(dirname "$(tracelink wsd)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/../../.systemConfig

process() {
    remote_repo=${1}
    local_repo=${2}

    (
        # Move to local git repo
        cd "$user_root"/"$repo_root"/"$local_repo"
        cur_branch=$(git branch --show-current)
        echo -e "Current branch: $cur_branch"

        # Find latest commit id
        last_commit_id=$(git log --max-count=1 | grep commit | cut -d' ' -f2)

        # FInd the path for this commit id and locate .changeTracker
        dest_commit_id="$workspace_backup_local"/"$(hostname)"/"$remote_repo"/"$cur_branch"/"$last_commit_id"

        cat "$dest_commit_id"/.changeTracker | cut -d'-' -f2 | uniq
    )

}

repoConfig="$curDir"/config/.allRepoConfig

for x in $(cat "$repoConfig"); do
    repo=$(echo "$x" | sed 's/\(.*\)#.*#.*/\1/')
    remote_repo=$(echo "$repo" | sed "s/.*\/$repo_username\/\(.*\)\.git/\1/")

    local_repo=$(echo "$x" | sed 's/.*#.*#\(.*\)/\1/')

    echo -e "\nRepo: $repo\nWorkspace: $user_root/$repo_root/$local_repo\n"
    process $remote_repo $local_repo

done
