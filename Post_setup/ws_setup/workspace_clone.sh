#!/usr/bin/env bash

if [[ -L $(which ws) ]]; then
    curDir="$(dirname "$(tracelink ws)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/../../.systemConfig

tempFile="$curDir"/tmp
wsConfig="$curDir"/config/.wsConfig

grep -v "^ *#" < "$wsConfig" | while IFS= read -r line
do
    remoterepo=$(echo "$line" | awk '{ print $1 }');
    branch=$(echo "$line" | awk '{ print $2 }');
    localrepo=$(echo "$line" | awk '{ print $3 }');
    tags=$(echo "$line" | awk '{ print $4 }');

    echo -e "\nRepo: $remoterepo\nBranch: $branch\nWorkspace: $user_devroot/$repo_root/$localrepo\n"
    git clone -b "$branch" "$remoterepo" "$user_devroot"/"$repo_root"/"$localrepo" 2>"$tempFile" || ([[ $(cat $tempFile | grep 'already exists') ]] && echo "Repo already exists" || echo "Error: $(cat $tempFile)")
done

[[ -e "$tempFile" ]] && rm "$tempFile"
echo -e "${BLUE}${BOLD}All repositories fetched${RESET}"
