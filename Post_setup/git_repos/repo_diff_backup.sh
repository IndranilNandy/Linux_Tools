#!/usr/bin/env bash

. ../../.systemConfig
# . ./config/.localConfig

process() {
    remote_repo=${1}
    local_repo=${2}
    branch=${3}

    (
        # Move to local git repo
        cd "$user_root"/"$repo_root"/"$local_repo"
        cur_branch=$(git branch --show-current)

        # FInd the target DESTBRANCH path -- diffBackupRootDir/hostname/remoteRepoName/currentBranch/
        dest_branch="$workspace_backup_local"/"$(hostname)"/"$remote_repo"/"$cur_branch"
        mkdir -p $dest_branch

        # Create a file .commitTracker in DESTBRANCH, tracking commit-id changes with respect to timestamp. Entry format>> timestamp:lastCommitId:ReadableDate
        last_commit_id=$(git log --max-count=1 | grep commit | cut -d' ' -f2)
        timeNowSecondsEpoch=$(date +%s)

        echo "$timeNowSecondsEpoch":"$last_commit_id":"$(date --date=@"$timeNowSecondsEpoch")" | tee "$dest_branch"/.commitTracker >/dev/null

        # FInd the target DEST path -- diffBackupRootDir/hostname/remoteRepoName/currentBranch/lastCommitId/
        dest="$dest_branch"/"$last_commit_id"
        mkdir -p "$dest"

        # Find untracked files and concat to .tmp in DEST
        git ls-files -o --exclude-standard | tee "$dest"/.tmp >/dev/null

        # Concat untracked files and git diff, and calculate sha1 checksum (REPOSHA)
        reposha=$(git diff | cat - "$dest"/.tmp | sha1sum | cut -d' ' -f1)

        # Create .changeTracker file in DEST, tracking repo status changes with respect to timestamp. Entry format>> timestamp:REPOSHA:ReadableDate
        echo "$timeNowSecondsEpoch":"$reposha":"$(date --date=@"$timeNowSecondsEpoch")" | tee "$dest"/.changeTracker >/dev/null

        dest_sha="$dest"/"$reposha"

        # If a directory with same REPOSHA id (DEST_SHA) exists, then there is no new change. So don't persist the changes, but update the .changeTracker file with last update-probe stat (timestamp:REPOSHA)
        [[ -d "$dest_sha" ]] && rm -rf "$dest"/.tmp && echo -e "Current checksum matches with the last checksum.No new change accumulated. Keeping entry of this probe in .changeTracker.\nDone and exiting." && exit 0

        # Create a folder named with REPOSHA id, to store untracked files in UNTRACKED directory and 'git diff' in TIMESTAMP.patch file
        mkdir -p "$dest_sha"/untracked

        # Put 'git diff' patch in DEST_SHA
        git diff | tee "$dest_sha"/"$timeNowSecondsEpoch".patch >/dev/null

        # Copy all the untracked files in DEST_SHA/untracked/
        cat "$dest"/.tmp | xargs -I X cp X "$dest_sha"/untracked/

        # Delete temporary file .tmp
        rm -rf "$dest"/.tmp

        # Copy localcopy of all workspaces into a remote host
        # Here we are using the host machine of this VM connected by XRDP
        cp -r "$workspace_backup_local" "$workspace_backup_remote"/
    )

}

echo -e "${BLUE}${BOLD}\nBacking up repo-diff started${RESET}"
echo -e "\nLocal Backup location: $workspace_backup_local\nRemote Backup location: $workspace_backup_remote"
for x in $(cat ./config/.allRepoConfig); do
    repo=$(echo "$x" | sed 's/\(.*\)#.*#.*/\1/')
    remote_repo=$(echo "$repo" | sed "s/.*\/$repo_username\/\(.*\)\.git/\1/")

    branch=$(echo "$x" | sed 's/.*#\(.*\)#.*/\1/')
    local_repo=$(echo "$x" | sed 's/.*#.*#\(.*\)/\1/')

    echo -e "\nRepo: $repo\nBranch: $branch\nWorkspace: $user_root/$repo_root/$local_repo\n"
    process $remote_repo $local_repo $branch

done

echo -e "${BLUE}${BOLD}\nBacking up repo-diff completed${RESET}"
