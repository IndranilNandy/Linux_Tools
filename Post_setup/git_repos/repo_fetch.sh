#!/usr/bin/env bash

. ../../.systemConfig
# . ./config/.localConfig

echo -e "${BLUE}${BOLD}Fetching all repositories${RESET}"
for x in $(cat ./config/.allRepoConfig); do
    # echo $x
    remoterepo=$(echo "$x" | sed 's/\(.*\)#.*#.*/\1/')
    branch=$(echo "$x" | sed 's/.*#\(.*\)#.*/\1/')
    localrepo=$(echo "$x" | sed 's/.*#.*#\(.*\)/\1/')

    echo -e "\nRepo: $remoterepo\nBranch: $branch\nWorkspace: $user_root/$repo_root/$localrepo\n"
    git clone -b "$branch" "$remoterepo" "$user_root"/"$repo_root"/"$localrepo" 2>./tmp || ([[ $(cat ./tmp | grep 'already exists') ]] && echo "Repo already exists" || echo "Error: $(cat ./tmp)")
done

[[ -e ./tmp ]] && rm ./tmp
echo -e "${BLUE}${BOLD}All repositories fetched${RESET}"
