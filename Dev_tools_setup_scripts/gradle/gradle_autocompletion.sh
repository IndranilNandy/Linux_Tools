#!/usr/bin/env bash

# https://github.com/gradle/gradle-completion

downloadCode() {
    [[ -d "$HOME/bash_completion.d" ]] || mkdir "$HOME/bash_completion.d"
    [[ -f "$HOME/bash_completion.d/gradle-completion.bash" ]] || curl -LA gradle-completion https://edub.me/gradle-completion-bash -o $HOME/bash_completion.d/gradle-completion.bash
}

update_env_var() {
    envloader="$MYCONFIGLOADER"/.envloader
    complloader="$HOME/bash_completion.d/gradle-completion.bash"
    [[ ! -f "$envloader" ]] && echo -e "[ERROR] .envloader doesn't exist. Check why it wasn't created as part of the full setup" && return 1

    [[ $(cat "$envloader" | grep -v "^#" | grep "source $complloader") ]] || echo "[[ -f $complloader ]] && source $complloader" >>"$envloader"
}

downloadCode && update_env_var