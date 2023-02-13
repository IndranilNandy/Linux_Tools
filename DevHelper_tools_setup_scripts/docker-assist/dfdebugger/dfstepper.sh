#!/usr/bin/env bash

if [ -L $(which dfdebugger) ]; then
    curDir="$(dirname "$(tracelink dfdebugger)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/configs/.config-params
. "$curDir"/components/process_dockerfile.sh

basedir=
dockerfile=
context=.
startline=
configoption=
showconfig=

findDockerfile() {
    find "$basedir" -name "*.dockerfile" -o -name "*.Dockerfile" >/tmp/dfilelist

    count_of_dockerfiles=$(cat /tmp/dfilelist | wc -l)

    ((count_of_dockerfiles == 0)) && echo -e "No Dockerfile found in the current directory hierarchy. Exiting." && return 1

    if ((count_of_dockerfiles == 1)); then
        dockerfile=$(basename -s .Dockerfile "$(basename -s .dockerfile "$(cat /tmp/dfilelist)")")
        basedir=$(dirname "$(cat /tmp/dfilelist)")
    else
        echo -e "Multiple Dockerfiles found in the current directory hierarchy!"
        cat /tmp/dfilelist | nl

        read -p "Which Dockerfile to choose? Enter the number: " no
        file=$(cat /tmp/dfilelist | nl | head -n$no | tail -n1 | cut -f2)

        dockerfile=$(basename -s .Dockerfile "$(basename -s .dockerfile "$file")")
        basedir=$(dirname "$file")
    fi
    echo -e "______________________________________________________________________________________"
    rm /tmp/dfilelist
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

    echo -e "______________________________________________________________________________________"
    echo "Validating parameters:\n"
    echo -e "______________________________________________________________________________________"

    echo -e "basedir=$basedir \ndockerfile=$dockerfile \ncontext=$context \nstartline=$startline\n"

    ! ([[ "$basedir" ]] && [[ -d "$basedir" ]]) && echo -e "Base directory doesn't exist. Exiting." && return 1
    ! ([[ "$dockerfile" ]] && ([[ -e "$basedir"/"$dockerfile".Dockerfile ]] || [[ -e "$basedir"/"$dockerfile".dockerfile ]])) && echo -e "Dockerfile doesn't exist. Exiting." && return 1
    ! ([[ "$context" ]] && [[ -d "$basedir"/"$context" ]]) && echo -e "Invalid context. Exiting." && return 1

    max_steps=$(cat "$basedir"/"$dockerfile".Dockerfile "$basedir"/"$dockerfile".dockerfile 2>/dev/null | grep -v "^#" | grep -v "^$" | wc -l)

    [[ "$startline" ]] || startline="$max_steps"
    ! ( ((startline >= 1)) && ((startline <= max_steps))) && echo -e "Invalid startline (should be between 1 and dockerfile-size." && return 1

    echo -e "DONE"
    echo -e "______________________________________________________________________________________"

    return 0
}

# Both . and .. allowed in the relative path
tr_path_rel_to_abs() {
    local path="${1}"
    path=$(echo "$path" | sed "s#^\.\.\(.*\)#$(dirname $(pwd))\1#")
    echo "$path" | sed "s#^\.\(.*\)#$(pwd)\1#"
}

# Either provide [option 1] --basedir/--dockerfile, or provide [option 2] full path (absolute/relative) of the dockerfile [NOT BOTH], or [option 3] provide NO input (context and startline are always accepted)
# Dockerfile names/paths should end with the extension (.dockerfile/.Dockerfile)
# [OPTION 1]
#        basedir accepts absolute/relative path
#        dockerfile accepts only name (with extension), no path should be preceeded
#        if basedir is NOT provided, then basedir is assumed to be current directory
#        if dockerfile is NOT provided, then the program searches for all dockerfiles in the directory tree pointed by basedir
#        if both are provided, then NO search is performed and basedir/dockerfile is taken as the full dockerfile path intended
# [OPTION 2]
#        accepts dockerfile with .dockerfile/.Dockerfile extension preceeded by absoulte/relative path
#        if only dockerfilename.ext is provided, then it takes the current directory as basedir
#        it does NOT do any dockerfile search, only accepts the given input
# [OPTION 3]
#        provide no input (as mentioned in Option 1 and 2) -> program will search for dockerfiles in the current directory
#        REMEMBER that context and startline values are always accepted if provided.
# --------------------------------------------------------------------------------------
# Context value is always relative to the basedir
# Default: .
# --------------------------------------------------------------------------------------
# startline value is validated for negative or out-of-range
# Default: the last step in dockerfile
# --------------------------------------------------------------------------------------

for arg in "$@"; do
    case $arg in
    --basedir=*)
        # Accepts both absolute and relative path
        if [[ "$basedir" ]]; then
            echo -e "Wrong usage of command arguments!"
            echo -e "You're setting basedir twice"
            exit 1
        fi
        basedir=$(echo $arg | sed "s/--basedir=\(.*\)/\1/")
        ;;
    --dockerfile=*)
        # Accepts only the dockerfile name with extension, no paths should be preceeded
        if [[ "$dockerfile" ]]; then
            echo -e "Wrong usage of command arguments!"
            echo -e "You're setting dockerfile twice"
            exit 1
        fi
        dockerfile=$(echo $arg | sed "s/--dockerfile=\(.*\)/\1/")
        dockerfile=$(basename -s .Dockerfile "$(basename -s .dockerfile "$dockerfile")")
        ;;
    --context=*)
        # Accepts path relative to the basedir only
        context=$(echo $arg | sed "s/--context=\(.*\)/\1/")
        ;;
    --startline=*)
        startline=$(echo $arg | sed "s/--startline=\(.*\)/\1/")
        ;;
    --config-edit-default)
        configoption="edit-default"
        echo -e "______________________________________________________________________________________"
        echo -e "Edit default config files"
        echo -e "______________________________________________________________________________________"
        ;;
    --config-create-and-set-as-current-for-this-run)
        configoption="create-config"
        echo -e "______________________________________________________________________________________"
        echo -e "Creating new config files (and stored in templates for this dockerfile) -> et as current confiuration for this run:"
        echo -e "______________________________________________________________________________________"
        ;;
    --config-select-and-set-as-current-for-this-run)
        configoption="set-current-for-run"
        echo -e "______________________________________________________________________________________"
        echo -e "Select config files (from templates collection of this dockerfile)-> set as current confiuration for this run:"
        echo -e "______________________________________________________________________________________"
        ;;
    --config-select-and-set-as-current-for-this-dockerfile)
        configoption="set-current-for-dockerfile"
        echo -e "______________________________________________________________________________________"
        echo -e "Select config files (from templates collection of this dockerfile)-> set as current confiuration for this dockerfile for any run:"
        echo -e "______________________________________________________________________________________"
        ;;
    --configs)
        showconfig="yes"
        ;;
    *.dockerfile)
        # Accepts dockerfile with .dockerfile/.Dockerfile extension preceeded by absoulte/relative path
        if [[ "$basedir" ]] || [[ "$dockerfile" ]]; then
            echo -e "Wrong usage of command arguments!"
            echo -e "Either you're setting basedir/dockerfile twice, or, you're providing multiple unnamed parameters, only one unnamed parameter (format: basedir/dockerfile) is valid"
            exit 1
        fi
        set_basedir_n_dockerfile "$arg" || exit 1
        ;;
    *.Dockerfile)
        # Accepts dockerfile with .dockerfile/.Dockerfile extension preceeded by absoulte/relative path
        if [[ "$basedir" ]] || [[ "$dockerfile" ]]; then
            echo -e "Wrong usage of command arguments!"
            echo -e "Either you're setting basedir/dockerfile twice, or, you're providing multiple unnamed parameters, only one unnamed parameter (format: basedir/dockerfile) is valid"
            exit 1
        fi
        set_basedir_n_dockerfile "$arg" || exit 1
        ;;
    *)
        echo -e "Invalid arguments. Exiting" && exit 1
        ;;
    esac
done

shopt -s extglob

# Note: 1 > If no basedir given (and no .Dockerfile is provided), then assume the indended dockerfile location to be current directory
[[ "$basedir" ]] || basedir=.

# Note: 2 > If at this point, still dockerfile isn't provided then the user intends to search it at directory tree pointed by basedir, which is again current directory if not explicitly provided by the user
[[ "$dockerfile" ]] || findDockerfile || exit 1

# If basedir is still empty here, that means --dockerfile option was provided by the user

basedir=$(tr_path_rel_to_abs "$basedir")
validate "$context" || exit 1
[[ "$showconfig" ]] && show_config_for_dockerfile "$basedir"/"$dockerfile" && exit 0

processDockerfile "$basedir" "$dockerfile" "$context" "$startline" "$configoption" || exit 1
