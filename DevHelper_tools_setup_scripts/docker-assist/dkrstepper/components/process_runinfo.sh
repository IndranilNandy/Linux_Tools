#!/usr/bin/env bash

if [ -L "$(which dfdebugger)" ]; then
    curDir="$(dirname "$(tracelink dfdebugger)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/configs/.config-params
. "$curDir"/components/process_sessioninfo.sh

run_status() {
    local run_id="${1}"
    # echo "[run_status] run_id=$run_id"

    local run_file=/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$runend_flag"
    # echo "run-file=$run_file"
    [[ ! -e "$run_file" ]] && echo "running" || cat "$run_file"
}

clean_container_req_for_run() {
    local run_id="${1}"
    local run_type="${2}"
    local run_status=$(run_status "$run_id")

    case $run_status in
    runaborted)
        clean_all_session_containers "$run_id"
        return 0
        ;;
    running)
        [[ "$run_type" == "all" ]] && clean_all_session_containers "$run_id"
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

clean_image_req_for_run() {
    local run_id="${1}"
    local run_type="${2}"

    local run_status=$(run_status "$run_id")

    case $run_status in
    runaborted)
        clean_all_session_images "$run_id"
        return 0
        ;;
    runexited)
        clean_all_session_images "$run_id"
        return 0
        ;;
    running)
        [[ "$run_type" == "all" ]] && clean_all_session_images "$run_id"
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

export_list() {
    export -f clean_container_req_for_run
    export -f clean_image_req_for_run
    export -f run_status
    export -f clean_all_session_containers
    export -f clean_all_session_images
    export -f cleanContainer
    export -f cleanImage

    export "dockerassist_root_dir"
    export "rundata_dir"
    export "runend_flag"
    export "dkr_dir"
    export "all_sessions_file"
    export "sessions_dir"
    export "session_containers"
    export "session_images"
}

cleanContainersInRun() {
    local run_type="${1}"
    cat /tmp/"$dockerassist_root_dir"/"$dfstepper_dir"/"$runid_file" | xargs -I X echo clean_container_req_for_run X "$run_type" | bash
}

cleanImagesInRun() {
    local run_type="${1}"
    cat /tmp/"$dockerassist_root_dir"/"$dfstepper_dir"/"$runid_file" | xargs -I X echo clean_image_req_for_run X "$run_type" | bash
}

cleanRun() {
    local run_type="${1}"
    local rs_type="${2}"

    export_list

    case "$rs_type" in
    all)
        cleanContainersInRun "$run_type"
        cleanImagesInRun "$run_type"
        ;;
    containers)
        cleanContainersInRun "$run_type"
        ;;
    images)
        cleanImagesInRun "$run_type"
        ;;
    *)
        ;;
    esac
}
