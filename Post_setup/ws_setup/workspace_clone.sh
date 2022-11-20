#!/usr/bin/env bash

if [[ -L $(which ws) ]]; then
    curDir="$(dirname "$(tracelink ws)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/../../.systemConfig

repoConfig="$curDir"/config/.allRepoConfig
tempFile="$curDir"/tmp

grep -v "^ *#" < "$repoConfig" | while IFS= read -r line
do
    remoterepo=$(echo "$line" | sed 's/\(.*\)#.*#.*/\1/')
    branch=$(echo "$line" | sed 's/.*#\(.*\)#.*/\1/')
    localrepo=$(echo "$line" | sed 's/.*#.*#\(.*\)/\1/')

    echo -e "\nRepo: $remoterepo\nBranch: $branch\nWorkspace: $user_devroot/$repo_root/$localrepo\n"
    git clone -b "$branch" "$remoterepo" "$user_devroot"/"$repo_root"/"$localrepo" 2>"$tempFile" || ([[ $(cat $tempFile | grep 'already exists') ]] && echo "Repo already exists" || echo "Error: $(cat $tempFile)")
done

[[ -e "$tempFile" ]] && rm "$tempFile"
echo -e "${BLUE}${BOLD}All repositories fetched${RESET}"
