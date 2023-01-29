#!/usr/bin/env bash

. ./.config-params
. ./process_dockerfile.sh

# basedir="$HOME/DEV/GIT-REPOS/PracticeWS/IDEwise/Vscode/Java/javatest2/app"
basedir=
# dockerfile=javatest2-sample1
dockerfile=
context=.
startline=1

processDockerfile() {
    basedir="${1}"
    dockerfile="${2}"
    local context="${3}"
    local startline="${4}"

    createIncrementalDockerfiles "$basedir" "$dockerfile" || echo -e "Cannot create incremental dockerfiles"

    evaluateIncrementalDockerfiles "$basedir" "$dockerfile" "$context" "$startline"
}

set_basedir_n_dockerfile() {
    arg="${1}"
    # TODO: if arg is null check for dockerfiles in current director and show list to choose from

    dockerfile=$(basename -s .Dockerfile "$(basename -s .dockerfile "$arg")")
    basedir=$(dirname "$arg")
    echo -e "basedir:$basedir dockerfile=$dockerfile"

    [[ ! -d "$basedir" ]] && echo -e "Base directory doesn't exist. Exiting." && return 1
    [[ ! -e "$basedir"/"$dockerfile".Dockerfile ]] && [[ ! -e "$basedir"/"$dockerfile".dockerfile ]] && echo -e "Dockerfile doesn't exist. Exiting." && return 1

    return 0
}

for arg in "$@"; do
    case $arg in
    --basedir=*)
        echo -e "basedir at first: $basedir"

        if [[ "$basedir" ]]; then
            echo -e "Wrong usage of command arguments!"
            echo -e "You're setting basedir twice"
            exit 1
        fi
        basedir=$(echo $arg | sed "s/--basedir=\(.*\)/\1/")
        [[ ! -d "$basedir" ]] && echo -e "Base directory doesn't exist. Exiting." && exit 1
        [[ "$dockerfile" ]] && [[ ! -e "$basedir"/"$dockerfile".Dockerfile ]] && [[ ! -e "$basedir"/"$dockerfile".dockerfile ]] && echo -e "Dockerfile doesn't exist. Exiting." && exit 1

        echo -e "basedir at first: $basedir"
        ;;
    --dockerfile=*)
        if [[ "$dockerfile" ]]; then
            echo -e "Wrong usage of command arguments!"
            echo -e "You're setting dockerfile twice"
            exit 1
        fi
        dockerfile=$(echo $arg | sed "s/--dockerfile=\(.*\)/\1/")
        [[ "$basedir" ]] && [[ ! -e "$basedir"/"$dockerfile".Dockerfile ]] && [[ ! -e "$basedir"/"$dockerfile".dockerfile ]] && echo -e "Dockerfile doesn't exist. Exiting." && exit 1
        ;;
    --context=*)
        context=$(echo $arg | sed "s/--context=\(.*\)/\1/")
        ;;
    --startline=*)
        startline=$(echo $arg | sed "s/--startline=\(.*\)/\1/")
        ;;
    *)
        echo -e "basedir at last: $basedir"
        if [[ "$basedir" ]] || [[ "$dockerfile" ]]; then
            echo -e "Wrong usage of command arguments!"
            echo -e "Either you're setting basedir/dockerfile twice, or, you're providing multiple unnamed parameters, only one unnamed parameter (format: basedir/dockerfile) is valid"
            exit 1
        fi
        set_basedir_n_dockerfile "$arg" || exit 1
        # if [[ ! $(set_basedir_n_dockerfile "$arg") ]]; then
        #     echo -e "Invalid basedir or dockerfile or both. Exiting."
        #     exit 1
        # fi
        echo -e "basedir at last: $basedir"

        ;;
    esac
done

processDockerfile "$basedir" "$dockerfile" "$context" "$startline"
