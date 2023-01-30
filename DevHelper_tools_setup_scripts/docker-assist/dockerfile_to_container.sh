#!/usr/bin/env bash

. ./.config-params
. ./process_dockerfile.sh

basedir=
dockerfile=
context=.
startline=1

processDockerfile() {
    basedir="${1}"
    dockerfile="${2}"
    local context="${3}"
    local startline="${4}"

    createIncrementalDockerfiles "$basedir" "$dockerfile" || echo -e "Cannot create incremental dockerfiles" || return 1
    evaluateIncrementalDockerfiles "$basedir" "$dockerfile" "$context" "$startline" || return 1
    return 0
}

findDockerfile() {
    echo "abcde"

    count_of_dockerfiles=$(find . -name "*.dockerfile" -o -name "*.Dockerfile" | wc -l)
    echo "abcd"
    ((count_of_dockerfiles == 0)) && return 1
    if ((count_of_dockerfiles == 1)); then
        echo -e "one"
        file=$(find . -name "*.dockerfile" -o -name "*.Dockerfile")
        # basedir="."
        dockerfile=$(basename -s .Dockerfile "$(basename -s .dockerfile "$file")")
        basedir=$(dirname "$file")

    else
        echo -e "multiple"
        echo -e "Select the number of the dockerfile:"
        find . -name "*.dockerfile" -o -name "*.Dockerfile" | nl
        read -p "Enter: " no
        # no=2
        echo "$no"
        file=$(find . -name "*.dockerfile" -o -name "*.Dockerfile" | nl | head -n$no | tail -n1 | cut -f2)
        echo "$file"
        # file=$(find . -name "*.dockerfile" -o -name "*.Dockerfile")
        # basedir="."
        dockerfile=$(basename -s .Dockerfile "$(basename -s .dockerfile "$file")")
        basedir=$(dirname "$file")
    fi
    return 0
}

set_basedir_n_dockerfile() {
    arg="${1}"

    dockerfile=$(basename -s .Dockerfile "$(basename -s .dockerfile "$arg")")
    basedir=$(dirname "$arg")
    echo -e "basedir:$basedir dockerfile=$dockerfile"

    [[ ! -d "$basedir" ]] && echo -e "Base directory doesn't exist. Exiting." && return 1
    [[ ! -e "$basedir"/"$dockerfile".Dockerfile ]] && [[ ! -e "$basedir"/"$dockerfile".dockerfile ]] && echo -e "Dockerfile doesn't exist. Exiting." && return 1

    return 0
}

validate() {
    local context="${1}"
    local startline="${2}"

    echo -e "Validating parameters:\n"

    echo -e "basedir=$basedir \ndockerfile=$dockerfile \ncontext=$context \nstartline=$startline\n"

    ! ([[ "$basedir" ]] && [[ -d "$basedir" ]]) && echo -e "Base directory doesn't exist. Exiting." && return 1
    ! ([[ "$dockerfile" ]] && ([[ -e "$basedir"/"$dockerfile".Dockerfile ]] || [[ -e "$basedir"/"$dockerfile".dockerfile ]])) && echo -e "Dockerfile doesn't exist. Exiting." && return 1
    ! ([[ "$context" ]] && [[ -d "$basedir"/"$context" ]]) && echo -e "Invalid context. Exiting." && return 1

    max_steps=$(cat "$basedir"/"$dockerfile".Dockerfile "$basedir"/"$dockerfile".dockerfile 2>/dev/null | grep -v "^#" | grep -v "^$" | wc -l)

    ! ( ((startline >= 1)) && ((startline <= max_steps))) && echo -e "Invalid startline (should be between 1 and dockerfile-size." && return 1

    echo -e "DONE"

    return 0
}

# Both . and .. allowed in the relative path
tr_path_rel_to_abs() {
    local path="${1}"
    path=$(echo "$path" | sed "s#^\.\.\(.*\)#$(dirname $(pwd))\1#")
    echo "$path" | sed "s#^\.\(.*\)#$(pwd)\1#"
}

for arg in "$@"; do
    case $arg in
    --basedir=*)
        if [[ "$basedir" ]]; then
            echo -e "Wrong usage of command arguments!"
            echo -e "You're setting basedir twice"
            exit 1
        fi
        basedir=$(echo $arg | sed "s/--basedir=\(.*\)/\1/")
        ;;
    --dockerfile=*)
        if [[ "$dockerfile" ]]; then
            echo -e "Wrong usage of command arguments!"
            echo -e "You're setting dockerfile twice"
            exit 1
        fi
        dockerfile=$(echo $arg | sed "s/--dockerfile=\(.*\)/\1/")
        dockerfile=$(basename -s .Dockerfile "$(basename -s .dockerfile "$dockerfile")")
        ;;
    --context=*)
        context=$(echo $arg | sed "s/--context=\(.*\)/\1/")
        ;;
    --startline=*)
        startline=$(echo $arg | sed "s/--startline=\(.*\)/\1/")
        ;;
    *)
        if [[ "$basedir" ]] || [[ "$dockerfile" ]]; then
            echo -e "Wrong usage of command arguments!"
            echo -e "Either you're setting basedir/dockerfile twice, or, you're providing multiple unnamed parameters, only one unnamed parameter (format: basedir/dockerfile) is valid"
            exit 1
        fi
        set_basedir_n_dockerfile "$arg" || exit 1
        ;;
    esac
done

shopt -s extglob

[[ "$basedir" ]] || [[ "$dockerfile" ]] || findDockerfile || exit 1
basedir=$(tr_path_rel_to_abs "$basedir")
validate "$context" "$startline" || exit 1
processDockerfile "$basedir" "$dockerfile" "$context" "$startline" || exit 1
