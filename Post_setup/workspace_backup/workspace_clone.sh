#!/usr/bin/env bash

if [[ -L $(which wsd) ]]; then
    curDir="$(dirname "$(tracelink wsd)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/../../.systemConfig

repoConfig="$curDir"/config/.allRepoConfig
tempFile="$curDir"/tmp

echo -e "${BLUE}${BOLD}Fetching all repositories${RESET}"
for x in $(cat $repoConfig); do
    # echo $x
    remoterepo=$(echo "$x" | sed 's/\(.*\)#.*#.*/\1/')
    branch=$(echo "$x" | sed 's/.*#\(.*\)#.*/\1/')
    localrepo=$(echo "$x" | sed 's/.*#.*#\(.*\)/\1/')

    echo -e "\nRepo: $remoterepo\nBranch: $branch\nWorkspace: $user_root/$repo_root/$localrepo\n"
    git clone -b "$branch" "$remoterepo" "$user_root"/"$repo_root"/"$localrepo" 2>$tempFile || ([[ $(cat $tempFile | grep 'already exists') ]] && echo "Repo already exists" || echo "Error: $(cat $tempFile)")
done

[[ -e "$tempFile" ]] && rm "$tempFile"
echo -e "${BLUE}${BOLD}All repositories fetched${RESET}"
