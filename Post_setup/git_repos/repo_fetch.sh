#!/usr/bin/env bash

. ../../.systemConfig
. ./config/.localConfig

echo -e "${BLUE}${BOLD}Fetching all repositories${RESET}"
for x in $(cat ./config/.allRepoConfig); do
    # echo $x
    repo=$(echo "$x" | sed 's/\(.*\)#.*#.*/\1/')
    branch=$(echo "$x" | sed 's/.*#\(.*\)#.*/\1/')
    dir=$(echo "$x" | sed 's/.*#.*#\(.*\)/\1/')

    echo $repo $branch $dir
    git clone -b "$branch" "$repo" "$userroot"/"$reporoot"/"$dir" 2>./tmp || [[ $(cat ./tmp | grep 'already exists') ]] && echo "Repo already exists" || echo "Error: $(cat ./tmp)"
done

[[ -e ./tmp ]] && rm ./tmp
echo -e "${BLUE}${BOLD}All repositories fetched${RESET}"
