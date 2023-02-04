#!/usr/bin/env bash

if [ -L "$(which dfdebugger)" ]; then
    curDir="$(dirname "$(tracelink dfdebugger)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/configs/.config-params
. "$curDir"/components/process_containers.sh
. "$curDir"/components/process_images.sh

init_run() {
    local run_id=$(date +%4Y%m%d%H%M%S)

    mkdir -p /tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id" || return 1
    echo $run_id >>/tmp/"$dockerassist_root_dir"/"$dfstepper_dir"/"$runid_file"
    return 0
}

get_current_run() {
    tail -n1 /tmp/"$dockerassist_root_dir"/"$dfstepper_dir"/"$runid_file" || return 1
}

init_session() {
    local run_id="${1}"
    local session_id=$(date +%4Y%m%d%H%M%S)

    mkdir -p /tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$sessions_dir"/"$session_id" || return 1
    echo $session_id >>/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$all_sessions_file"
    return 0
}

get_current_session() {
    local run_id="${1}"

    tail -n1 /tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$all_sessions_file" || return 1
}

run_end() {
    local run_id="${1}"
    local run_status="${2}"
    echo "$run_status" > /tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$runend_flag"
}

run_ended() {
    local run_id="${1}"

    [[ -e /tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$runend_flag" ]] || return 1
}

clean_all_sessions() {
    local run_id="${1}"

    rm /tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$all_sessions_file" || return 1
}

session_exists() {
    local run_id="${1}"

    [[ -e /tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$all_sessions_file" ]] || return 1
}

sessions_cleared() {
    local run_id="${1}"

    ! session_exists "$run_id" || return 1
}

add_session_image() {
    local image="${1}"
    local session_id="${2}"
    local run_id="${3}"

    local file=/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$sessions_dir"/"$session_id"/"$session_images"

    [[ -e "$file" ]] && grep -q -E "^$image$" "$file" || echo "$image" >>"$file"
}

add_session_container() {
    local container="${1}"
    local session_id="${2}"
    local run_id="${3}"

    local file=/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$sessions_dir"/"$session_id"/"$session_containers"

    [[ -e "$file" ]] && grep -q -E "^$container$" "$file" || echo "$container" >>"$file"
}

update_current_step_info() {
    local curline="${1}"
    local run_id="${2}"

    echo "$curline" >/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$curstep"
}

cur_step() {
    local run_id="${1}"

    cat /tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$curstep"
}
