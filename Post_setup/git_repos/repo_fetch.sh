#!/usr/bin/env bash

. ../../.systemConfig.sh
. ./config/.localConfig.sh

# echo $testvar

echo -e "${BLUE}${BOLD}Fetching all repositories${RESET}"
for x in $(cat ./config/.allRepoConfig); do
    # echo $x
    repo=$(echo "$x" | sed 's/\(.*\)#.*#.*/\1/')
    branch=$(echo "$x" | sed 's/.*#\(.*\)#.*/\1/')
    dir=$(echo "$x" | sed 's/.*#.*#\(.*\)/\1/')

    echo $repo $branch $dir
    git clone -b "$branch" "$repo" "$userroot"/"$reporoot"/"$dir"

    # if [[ $(ifinstalled $cmd) ]]; then
    #     echo "$tool:installed"
    # else
    #     case $cmd in
    #     winmerge)
    #         if [[ -e $HOME/'.wine/drive_c/Program Files/WinMerge/WinMergeU.exe' ]]; then
    #             echo "$tool:installed"
    #         else
    #             echo "$tool:NOT installed"
    #         fi
    #         ;;
    #     *)
    #         echo "$tool:NOT installed"
    #         ;;
    #     esac
    # fi
done

echo -e "${BLUE}${BOLD}All repositories fetched${RESET}"
