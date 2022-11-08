#!/usr/bin/env bash

# https://github.com/gradle/gradle-completion

downloadCode() {
    [[ -d "$HOME/bash_completion.d" ]] || mkdir "$HOME/bash_completion.d"
    [[ -f "$HOME/bash_completion.d/gradle-completion.bash" ]] || curl -LA gradle-completion https://edub.me/gradle-completion-bash -o $HOME/bash_completion.d/gradle-completion.bash
}

update_env_var() {
    envloader="$MYCONFIGLOADER"/.envloader
    [[ ! -f "$envloader" ]] && echo -e "[ERROR] .envloader doesn't exist. Check why it wasn't created as part of the full setup" && return 1

    env_var="source $HOME/bash_completion.d/gradle-completion.bash"
    grep -q "$env_var" "$envloader" || echo "$env_var" >> "$envloader"
}

downloadCode && update_env_var
