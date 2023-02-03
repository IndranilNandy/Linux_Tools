#!/usr/bin/env bash

if [ -L "$(which dkrstepper)" ]; then
    curDir="$(dirname "$(tracelink dkrstepper)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/configs/.config-params
. "$curDir"/components/process_containers.sh
. "$curDir"/components/process_images.sh

init_run() {
    local run_id=$(date +%4Y%m%d%H%M%S)

    mkdir -p /tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id" || return 1
    echo $run_id >>/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$runid_file"
    return 0
}

get_current_run() {
    tail -n1 /tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$runid_file" || return 1
}

init_session() {
    local run_id="${1}"
    local session_id=$(date +%4Y%m%d%H%M%S)

    mkdir -p /tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$session_id" || return 1
    echo $session_id >>/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$all_sessions_file"
    return 0
}

get_current_session() {
    local run_id="${1}"

    tail -n1 /tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$all_sessions_file" || return 1
}

run_end() {
    local run_id="${1}"

    touch /tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$runend_flag"
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

    local file=/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$session_id"/"$session_images"

    [[ -e "$file" ]] && grep -q -E "^$image$" "$file" || echo "$image" >>"$file"
}

add_session_container() {
    local container="${1}"
    local session_id="${2}"
    local run_id="${3}"

    local file=/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$session_id"/"$session_containers"

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

# testfn() {
#     container="${1}"
#     echo "container = $container"
# }

clean_all_session_containers() {
    local run_id="${1}"

    dkr_dir=/tmp/"$dockerassist_root_dir"/"$rundata_dir"
    sessions_file="$dkr_dir"/"$run_id"/"$all_sessions_file"
    export -f cleanContainer

    echo -e "______________________________________________________________________________________"
    echo -e "CLEANING ALL SESSION CONTAINERS"
    echo -e "______________________________________________________________________________________"

    cat "$sessions_file" | xargs -I X echo "cat $dkr_dir"/"$run_id"/X/"$session_containers" | bash | xargs -I X echo "cleanContainer X" | bash
}

clean_all_session_images() {
    local run_id="${1}"

    dkr_dir=/tmp/"$dockerassist_root_dir"/"$rundata_dir"
    sessions_file="$dkr_dir"/"$run_id"/"$all_sessions_file"
    export -f cleanImage

    echo -e "______________________________________________________________________________________"
    echo -e "CLEANING ALL SESSION IMAGES"
    echo -e "______________________________________________________________________________________"

    cat "$sessions_file" | xargs -I X echo "cat $dkr_dir"/"$run_id"/X/"$session_images" | bash | xargs -I X echo "cleanImage X" | bash
}

# init_session
# x=$(get_current_session || echo "failed")
# echo "last: $x"

# clean_all_sessions
# sessions_cleared && echo cleared || echo not cleared
# session_exists && echo exists || echo not exists

# sid=20230202204617
# add_session_image "123" "$sid"
# add_session_image "345" "$sid"
# add_session_image "123" "$sid"
# add_session_image "444" "$sid"

# update_current_step_info 12
# echo "$(cur_step)"

# clean_all_session_containers
# clean_all_session_images