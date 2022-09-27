#!/usr/bin/env bash

ifAllInstalled() {
    for ver in $(cat $(pwd)/.jdkversions | grep -E -v " *#"); do
        instl_script=" source ~/.bashrc; \
echo \"Installing version: $ver\"; \
yes no | sdk install java $ver || exit 1; \
exit 0 "
        echo -e "$instl_script"
        bash --init-file <(echo "$instl_script;") || return 1
    done
    return 0
}

ifAllInstalled || echo -e "not all installed" && exit 1
