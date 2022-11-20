#!/usr/bin/env bash

if [[ -L $(which ws) ]]; then
    curDir="$(dirname "$(tracelink ws)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/../../.systemConfig

tempFile="$curDir"/tmp
wsConfig="$curDir"/config/.wsConfig

add_quicklink() {
    dir_alias=${1}
    dir_target=${2}
    echo "alias=$dir_alias target=$dir_target which=$(which myfunc)"

    instl_script=" source ~/.bashrc; \
echo \"Installing version: $dir_alias\"; \
exit 0 "

    bash --init-file <(echo "$instl_script;")
}

grep -v "^ *#" <"$wsConfig" | while IFS= read -r line; do
    remoterepo=$(echo "$line" | awk '{ print $1 }')
    shouldDwld=$(echo "$line" | awk '{ print $2 }')
    branch=$(echo "$line" | awk '{ print $3 }')
    localrepo=$(echo "$line" | awk '{ print $4 }')
    tags=$(echo "$line" | awk '{ print $5 }')
    qlink=$(echo "$line" | awk '{ print $6 }')

    echo -e "\nRepo: $remoterepo\nBranch: $branch\nWorkspace: $user_devroot/$repo_root/$localrepo\nShould download?: $(echo "$shouldDwld" | tr [:upper:] [:lower:])\nTags: $tags\nQuicklink: $qlink\n"
    [ $(echo "$shouldDwld" | tr [:upper:] [:lower:]) == "n" ] || git clone -b "$branch" "$remoterepo" "$user_devroot"/"$repo_root"/"$localrepo" 2>"$tempFile" || ([[ $(cat $tempFile | grep 'already exists') ]] && echo "Repo already exists" || echo "Error: $(cat $tempFile)")
    [ -z "$qlink" ] || echo "$qlink" "$user_devroot"/"$repo_root"/"$localrepo"

    [ -z "$qlink" ] || add_quicklink "$qlink" "$user_devroot"/"$repo_root"/"$localrepo"

done

[[ -e "$tempFile" ]] && rm "$tempFile"
echo -e "${BLUE}${BOLD}All repositories fetched${RESET}"
