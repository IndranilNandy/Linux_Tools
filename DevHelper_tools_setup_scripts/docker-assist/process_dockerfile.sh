#!/usr/bin/env bash

# . ./.config-params
. ./process_containers.sh
. ./process_images.sh

removeComments() {
    local basedir="${1}"
    local dockerfile="${2}"
    local processed_dfile="${3}"
    local ext=".Dockerfile"

    cat "$basedir"/"$dockerfile""$ext" | grep -v "^#" | grep -v "^$" >"${basedir}"/"$dockerassist_root_dir"/"$processed_dfile""$ext"
}

createIncrementalDockerfiles() {
    local basedir="${1}"
    local dockerfile="${2}"
    local processed_dfile="$dockerfile-full"
    local ext=".Dockerfile"

    mkdir -p "${basedir}"/"$dockerassist_root_dir"
    (
        cd "${basedir}"/"$dockerassist_root_dir" || return 1
        removeComments "$basedir" "$dockerfile" "$processed_dfile"

        local lines=$(wc -l "${basedir}"/"$dockerassist_root_dir"/"$processed_dfile""$ext" | cut -f1 -d' ')
        mkdir -p "$incr_dfiles_dir" || return 1

        local entrypoint="ENTRYPOINT [ \"/bin/sh\" ]"

        for ((i = 1; i <= "lines"; i++)); do
            head -n"$i" "$processed_dfile""$ext" >"$incr_dfiles_dir"/incr-"$i""$ext"
            echo "$entrypoint" >>"$incr_dfiles_dir"/incr-"$i""$ext"
            echo "Created ""$incr_dfiles_dir"/incr-"$i""$ext"

        done
    )
}

processIncrementalDockerfiles() {
    local basedir="${1}"
    local incr_dockerfile="${2}"
    local image_name="${3}"
    local image_version="${4}"
    local context="${5}"
    local container_name="${6}"
    # local ext=".Dockerfile"

    echo -e "createContainer \n\t\tbasedir=:$basedir/$dockerassist_root_dir/$incr_dfiles_dir \
                                    \n\t\tdockerfile=$incr_dockerfile \
                                    \n\t\timage=$image_name:$image_version \
                                    \n\t\tcontext=$context \
                                    \n\t\tcontainer=$container_name\n"

    createContainer "$basedir"/"$dockerassist_root_dir"/"$incr_dfiles_dir" "$incr_dockerfile" "$image_name" "$image_version" "../../""$context" "$container_name"

}

prompt() {
    local curline="${1}"
    local total_steps="${2}"
    local step_status="${3}"
    local ans="${4}"

    read -p "n[next] or p[prev] or line#[e.g. 12] or s[skip] or a[abort] or e[exit] or c[clean] " ans
    ans=$(echo "$ans" | tr [:upper:] [:lower:])
    case $ans in
    n)
        ((curline < total_steps)) && ((curline++)) && step_status="changed" || step_status="unchanged"
        ;;
    p)
        ((curline > 1)) && ((curline--)) && step_status="changed" || step_status="unchanged"
        ;;
    [[:digit:]]*)
        ((ans != curline)) && ((ans >= 1)) && ((ans <= total_steps)) && ((curline = ans)) && step_status="changed" || step_status="unchanged"
        ;;
    +[[:digit:]]*)
        ahead=$(echo $ans | cut -c2-)
        target_line=$((curline + ahead))
        ((target_line != curline)) && ((target_line <= total_steps)) && ((curline = target_line)) && step_status="changed" || step_status="unchanged"
        ;;
    -[[:digit:]]*)
        ahead=$(echo $ans | cut -c2-)
        target_line=$((curline - ahead))
        ((target_line != curline)) && ((target_line >= 1)) && ((curline = target_line)) && step_status="changed" || step_status="unchanged"
        ;;
    s) ;;

    a)
        step_status="aborted"
        ;;
    e)
        step_status="exited"
        ;;
    c)
        step_status="cleaned"
        ;;
    *) ;;

    esac

    echo "$curline $step_status $ans"
}

clean() {
    local basedir="${1}"
    local dockerfile="${2}"
    local step_status="${3}"
    local -n version_set_lref=${4}

    case "$step_status" in
    aborted)
        echo -e "Images and Containers are NOT cleaned. Needs to be CLEANED MANUALLY."
        echo -e "Remove docker-assist-dir MANUALLY"
        ;;
    exited)
        cleanContainers "$dockerfile" version_set_lref
        echo -e "Images are NOT cleaned. Need to clean manually."
        echo -e "Remove docker-assist-dir MANUALLY"
        echo -e "Containers are REMOVED."
        ;;
    cleaned)
        cleanContainers "$dockerfile" version_set_lref
        cleanImages "$dockerfile" version_set_lref
        rm -r "${basedir:?}"/"$dockerassist_root_dir"
        echo -e "Images and Containers are CLEANED."
        echo -e "docker-assist-dir is REMOVED"

        ;;
    *)
        echo -e "INVALID STATE"
        echo -e "Everything NEEDS to be MANUALLY CLEANED"
        echo -e "Remove docker-assist-dir MANUALLY"
        ;;
    esac
}
evaluateIncrementalDockerfiles() {
    local basedir="${1}"
    local dockerfile="${2}"
    local context="${3}"
    local startline="${4}"
    local ext=".Dockerfile"

    local curline=$((startline))
    local image_name=$(echo i-"$dockerfile" | tr [:upper:] [:lower:])
    local total_steps=$(ls -1 | wc -l | cut -f1 -d' ')
    local ans=o # o: OK
    local step_status="changed"

    declare -A version_set

    cur_dir=$(pwd)

    cd "${basedir}"/"$dockerassist_root_dir"/"$incr_dfiles_dir" || return 1

    local total_steps=$(ls -1 | wc -l | cut -f1 -d' ')

    echo -e "\nTotal steps: $total_steps"

    while [ ! "$ans" = "e" ] && [ ! "$ans" = "a" ] && [ ! "$ans" = "c" ]; do
        echo -e "______________________________________________________________________________________"
        echo -e "Running step# $curline/$total_steps"
        echo -e "______________________________________________________________________________________"

        local incr_dockerfile="incr-""$curline"
        echo -e "\nProcessing $incr_dockerfile$ext:\n"
        # echo -e "total_steps=$total_steps"

        local image_version="$curline"
        local container_name=$(echo c-"$dockerfile"-"$image_version" | tr [:upper:] [:lower:])

        echo -e "[debug] step_status = $step_status"

        case "$step_status" in
        changed)
            # echo -e "[debug] step_status = $step_status"
            version_set["$curline"]=1
            processIncrementalDockerfiles "$basedir" "$incr_dockerfile" "$image_name" "$image_version" "$context" "$container_name"
            ;;
        unchanged)
            echo -e "Step# unchanged. Not processing."
            ;;
        esac

        echo -e
        echo -e "Current step# $curline/$total_steps"

        iter_status=$(prompt "$curline" "$total_steps" "$step_status" "$ans")
        # echo "iter_status = $iter_status"

        curline=$(echo "$iter_status" | cut -f1 -d' ')
        step_status=$(echo "$iter_status" | cut -f2 -d' ')
        ans=$(echo "$iter_status" | cut -f3 -d' ')
    done

    cd "$cur_dir" || return 1

    clean "$basedir" "$dockerfile" "$step_status" version_set
}
