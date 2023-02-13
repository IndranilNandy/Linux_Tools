#!/usr/bin/env bash

if [ -L $(which dfdebugger) ]; then
    curDir="$(dirname "$(tracelink dfdebugger)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/components/process_containers.sh
. "$curDir"/components/process_images.sh
. "$curDir"/components/process_sessioninfo.sh
. "$curDir"/components/process_runinfo.sh

prompt() {
    local curline="${1}"
    local total_steps="${2}"
    local step_status="${3}"
    local ans="${4}"

    shopt -s extglob

    read -p $'
    fr      [change (and edit, if needed) config of this dockerfile for all sessions of this run]-------[eq change-config + reload (r)]-|
    fd      [change (and edit, if needed) default "current-config" of this dockerfile for all runs]-----[eq change-config + reload (r)]-|
    fc      [create new config files for this dockerfile]                                                                               |
    f       [show all config files and point to the config files for this dockerfile or current run]                                    |
    n       [next step in current session]                                                                                              |
    p       [prev step in current session]                                                                                              |
    line#   [to line# in current session]---------------------------------------------------------------[e.g. 12]-----------------------|
    +/-step [forward/backward steps in current session]-------------------------------------------------[e.g. +5/-5]--------------------|
    +s/s    [skip forward in current session]                                                                                           |
    -s      [skip backward in current session]                                                                                          |
    a       [abort current session -> reload next session]                                                                              |
    e       [exit current session -> reload next session]                                                                               |
    c       [clean exit current session -> reload next session]                                                                         |
    r       [abort current session -> reload next session]----------------------------------------------[eq a]--------------------------|
    xa      [abort all sessions -> exit run]                                                                                            |
    xe      [exit all sessions -> exit run]                                                                                             |
    xc      [clean exit all sessions -> exit run]                                                                                       |
    x       [clean exit all sessions -> exit run]-------------------------------------------------------[eq xc]-------------------------|
    > ' ans

    ans=$(echo "$ans" | tr [:upper:] [:lower:])
    case $ans in
    fr)
        step_status="configchangedforthisrun"
        ;;
    fd)
        step_status="configchangedforthisdockerfile"
        ;;
    fc)
        step_status="configcreated"
        ;;
    f)
        step_status="showconfigandthenunchanged"
        ;;
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
    s)
        ((curline < total_steps)) && ((curline++))
        step_status="skipped"
        ;;
    +s)
        ((curline < total_steps)) && ((curline++))
        step_status="skipped"
        ;;
    -s)
        ((curline > 1)) && ((curline--))
        step_status="skipped"
        ;;
    a)
        step_status="sessionaborted"
        ;;
    e)
        step_status="sessionexited"
        ;;
    c)
        step_status="sessioncleaned"
        ;;
    r)
        step_status="reloaded"
        ;;
    xa)
        step_status="runaborted"
        ;;
    xe)
        step_status="runexited"
        ;;
    xc)
        step_status="runcleaned" # fully exited
        ;;
    x)
        step_status="exited" # fully exited with no trace. Previous and this case are equivalent.
        ;;
    *)
        step_status="invalid"
        ;;
    esac

    echo "$curline $step_status $ans"
}

sessionClean() {
    local basedir="${1}"
    local dockerfile="${2}"
    local step_status="${3}"
    local -n version_set_lref=${4}
    local session_id="${5}"
    local run_id="${6}"

    case "$step_status" in
    configcreated)
        echo -e "Creating new configs"
        createConfigFiles "$basedir"/"$dockerfile" "$run_id"
        ;;
    configchangedforthisrun)
        updateConfigFiles "$basedir"/"$dockerfile" "$run_id"
        echo -e "Reloading..."
        echo -e "Images and Containers are NOT cleaned. Needs to be CLEANED MANUALLY."
        echo -e "Remove docker-assist-dir MANUALLY"
        ;;
    configchangedforthisdockerfile)
        updateCurrentConfigFiles "$basedir"/"$dockerfile" "$run_id"
        echo -e "Reloading..."
        echo -e "Images and Containers are NOT cleaned. Needs to be CLEANED MANUALLY."
        echo -e "Remove docker-assist-dir MANUALLY"
        ;;
    sessionaborted)
        echo -e "Images and Containers are NOT cleaned. Needs to be CLEANED MANUALLY."
        echo -e "Remove docker-assist-dir MANUALLY"
        ;;
    sessionexited)
        cleanContainers "$dockerfile" version_set_lref "$session_id" "$run_id"
        echo -e "Images are NOT cleaned. Need to clean manually."
        echo -e "Remove docker-assist-dir MANUALLY"
        echo -e "Containers are REMOVED."
        ;;
    sessioncleaned)
        cleanContainers "$dockerfile" version_set_lref "$session_id" "$run_id"
        cleanImages "$dockerfile" version_set_lref "$session_id" "$run_id"
        # rm -r "${basedir:?}"/"$dockerassist_root_dir"
        echo -e "Images and Containers are CLEANED."
        echo -e "docker-assist-dir is REMOVED"
        ;;
    reloaded)
        echo -e "Images and Containers are NOT cleaned. Needs to be CLEANED MANUALLY."
        echo -e "Remove docker-assist-dir MANUALLY"
        ;;
    runaborted)
        run_end "$run_id" "$step_status"

        echo -e "Images and Containers are NOT cleaned. Needs to be CLEANED MANUALLY."
        echo -e "Remove docker-assist-dir MANUALLY"
        ;;
    runexited)
        clean_all_session_containers "$run_id"
        run_end "$run_id" "$step_status"

        echo -e "Images are NOT cleaned. Need to clean manually."
        echo -e "Remove docker-assist-dir MANUALLY"
        echo -e "Containers are REMOVED."
        ;;
    runcleaned)
        clean_all_session_containers "$run_id"
        clean_all_session_images "$run_id"
        run_end "$run_id" "$step_status"

        # rm -r "${basedir:?}"/"$dockerassist_root_dir"
        echo -e "Images and Containers are CLEANED."
        echo -e "docker-assist-dir is REMOVED"
        ;;
    exited)
        clean_all_session_containers "$run_id"
        clean_all_session_images "$run_id"
        run_end "$run_id" "$step_status"

        # rm -r "${basedir:?}"/"$dockerassist_root_dir"
        ;;
    *)
        echo -e "INVALID STATE"
        echo -e "Everything NEEDS to be MANUALLY CLEANED"
        echo -e "Remove docker-assist-dir MANUALLY"
        ;;
    esac
}

removeComments() {
    local basedir="${1}"
    local dockerfile="${2}"
    local processed_dfile="${3}"
    local session_id="${4}"
    local run_id="${5}"

    local ext=".Dockerfile"

    cat "$basedir"/"$dockerfile".Dockerfile "$basedir"/"$dockerfile".dockerfile 2>/dev/null | grep -v "^#" | grep -v "^$" >/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$sessions_dir"/"$session_id"/"$processed_dfile""$ext"
}

createIncrementalDockerfiles() {
    local basedir="${1}"
    local dockerfile="${2}"
    local session_id="${3}"
    local run_id="${4}"

    local processed_dfile="$dockerfile-full"
    local ext=".Dockerfile"

    echo -e "______________________________________________________________________________________"
    echo -e "Creating Incremental Dockerfiles"
    echo -e "______________________________________________________________________________________"

    # mkdir -p /tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$session_id"
    (
        cd /tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$sessions_dir"/"$session_id" || return 1
        removeComments "$basedir" "$dockerfile" "$processed_dfile" "$session_id" "$run_id"

        local lines=$(wc -l /tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$sessions_dir"/"$session_id"/"$processed_dfile""$ext" | cut -f1 -d' ')
        mkdir -p "$incr_dfiles_dir" || return 1

        local entrypoint="ENTRYPOINT [ \"/bin/sh\" ]"

        for ((i = 1; i <= "lines"; i++)); do
            head -n"$i" "$processed_dfile""$ext" >"$incr_dfiles_dir"/incr-"$i""$ext"
            # echo "$entrypoint" >>"$incr_dfiles_dir"/incr-"$i""$ext"
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
    local session_id="${7}"
    local run_id="${8}"
    # local ext=".Dockerfile"

    echo -e "createContainer \n\t\tbasedir=:$basedir \
                                    \n\t\tdockerfile=$incr_dockerfile \
                                    \n\t\timage=$image_name:$image_version \
                                    \n\t\tcontext=$context \
                                    \n\t\tcontainer=$container_name \
                                    \n\t\tdockerfile_dir=/tmp/$dockerassist_root_dir/$rundata_dir/$run_id/$sessions_dir/$session_id/$incr_dfiles_dir\n"

    createContainer "$basedir" "$incr_dockerfile" "$image_name" "$image_version" "$context" "$container_name" /tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$sessions_dir"/"$session_id"/"$incr_dfiles_dir" "$run_id"

}

evaluateIncrementalDockerfiles() {
    local basedir="${1}"
    local dockerfile="${2}"
    local context="${3}"
    local startline="${4}"
    local session_id="${5}"
    local run_id="${6}"

    local ext=".Dockerfile"

    # echo -e "[evaluateIncrementalDockerfiles] basedir=$basedir dockerfile=$dockerfile context=$context startline=$startline"

    local curline=$((startline))
    local image_name=$(echo i-"$dockerfile" | tr [:upper:] [:lower:])
    # local total_steps=$(ls -1 | wc -l | cut -f1 -d' ')
    local ans=o # o: OK
    local step_status="changed"

    declare -A version_set

    local incr_dir=/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$sessions_dir"/"$session_id"/"$incr_dfiles_dir"
    local total_steps=$(ls -1 "$incr_dir" | wc -l | cut -f1 -d' ')

    echo -e "\nTotal steps: $total_steps"

    ((curline > total_steps)) && echo -e "startline value is more than the size of the dockerfile. Setting it to last step" && curline=$((total_steps))

    while [ ! "$ans" = "fc" ] && \
            [ ! "$ans" = "fr" ] && \
            [ ! "$ans" = "fd" ] && \
            [ ! "$ans" = "e" ] && \
            [ ! "$ans" = "a" ] && \
            [ ! "$ans" = "c" ] && \
            [ ! "$ans" = "r" ] && \
            [ ! "$ans" = "x" ] && \
            [ ! "$ans" = "xa" ] && \
            [ ! "$ans" = "xe" ] && \
            [ ! "$ans" = "xc" ]; do
        echo -e "______________________________________________________________________________________"
        echo -e "Running step# $curline/$total_steps"
        echo -e "______________________________________________________________________________________"

        local incr_dockerfile="incr-""$curline"
        echo -e "\nProcessing $incr_dockerfile$ext:\n"

        local image_version="$curline"
        local container_name=$(echo c-"$dockerfile"-"$session_id"-"$image_version" | tr [:upper:] [:lower:])

        # echo -e "[debug] step_status = $step_status"

        case "$step_status" in
        changed)
            # echo -e "[debug] step_status = $step_status"
            version_set["$curline"]=1
            add_session_image "$image_name"-"$session_id":"$image_version" "$session_id" "$run_id"
            add_session_container "$container_name" "$session_id" "$run_id"
            processIncrementalDockerfiles "$basedir" "$incr_dockerfile" "$image_name"-"$session_id" "$image_version" "$context" "$container_name" "$session_id" "$run_id"
            ;;
        unchanged)
            echo -e "Step# unchanged. Not processing."
            ;;
        skipped)
            echo -e "Step# $curline skipped"
            ;;
        showconfigandthenunchanged)
            echo -e "Showing all configs."
            show_config "$run_id" "$basedir"/"$dockerfile"
            step_status="unchanged"
            ;;
        invalid)
            echo -e "INVALID STATE/INPUT"
            ;;
        esac

        echo -e
        echo -e "Current step# $curline/$total_steps"
        echo -e "______________________________________________________________________________________"

        iter_status=$(prompt "$curline" "$total_steps" "$step_status" "$ans")
        # echo "iter_status = $iter_status"

        curline=$(echo "$iter_status" | cut -f1 -d' ')
        step_status=$(echo "$iter_status" | cut -f2 -d' ')
        ans=$(echo "$iter_status" | cut -f3 -d' ')
    done

    update_current_step_info "$curline" "$run_id"
    sessionClean "$basedir" "$dockerfile" "$step_status" version_set "$session_id" "$run_id"
    # echo "[evaluateIncrementalDockerfiles] curline=$curline step_status=$step_status ans=$ans"

    return 0
}

processDockerfile() {
    local basedir="${1}"
    local dockerfile="${2}"
    local context="${3}"
    local startline="${4}"
    local configoption="${5}"

    local curline="$startline"
    local session_id=
    local run_id=

    init_run && run_id=$(get_current_run || echo "-1")
    init_config "$run_id" "$basedir"/"$dockerfile" "$configoption"

    while true; do
        # echo -e "[processDockerfile][debug] basedir=$basedir dockerfile=$dockerfile context=$context startline=$startline curline=$curline"

        init_session "$run_id" && session_id=$(get_current_session "$run_id" || echo "-1")

        createIncrementalDockerfiles "$basedir" "$dockerfile" "$session_id" "$run_id" || echo -e "Cannot create incremental dockerfiles" || return 1
        evaluateIncrementalDockerfiles "$basedir" "$dockerfile" "$context" "$curline" "$session_id" "$run_id" || return 1

        run_ended "$run_id" && return 0
        curline=$(cur_step "$run_id")
    done
    return 0
}
