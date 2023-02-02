#!/usr/bin/env bash

if [ -L "$(which dkrstepper)" ]; then
    curDir="$(dirname "$(tracelink dkrstepper)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/configs/.config-params

init_session() {
    local session_id=$(date +%4Y%m%d%H%M%S)
    mkdir -p /tmp/"$dockerassist_root_dir"/"$dkrstepper_dir"/"$session_id" || return 1
    echo $session_id >> /tmp/"$dockerassist_root_dir"/"$dkrstepper_dir"/"$all_sessions_file"
    return 0
}

get_current_session() {
    tail -n1 /tmp/"$dockerassist_root_dir"/"$dkrstepper_dir"/"$all_sessions_file" || return 1
}

clean_all_sessions() {
    rm /tmp/"$dockerassist_root_dir"/"$dkrstepper_dir"/"$all_sessions_file" || return 1
}

session_exists() {
    [[ -e /tmp/"$dockerassist_root_dir"/"$dkrstepper_dir"/"$all_sessions_file" ]] || return 1
}

sessions_cleared() {
    ! session_exists || return 1
}

add_session_image() {
    local image="${1}"
    local session_id="${2}"
    local file=/tmp/"$dockerassist_root_dir"/"$dkrstepper_dir"/"$session_id"/"$session_images"

    [[ -e "$file" ]] && grep -q -E "^$image$" "$file" || echo "$image" >> "$file"
}

add_session_container() {
    local container="${1}"
    local session_id="${2}"
    local file=/tmp/"$dockerassist_root_dir"/"$dkrstepper_dir"/"$session_id"/"$session_containers"

    [[ -e "$file" ]] && grep -q -E "^$container$" "$file" || echo "$container" >> "$file"
}

update_current_step_info() {
    local curline="${1}"
    echo "$curline" > /tmp/"$dockerassist_root_dir"/"$dkrstepper_dir"/"$curstep"
}

cur_step() {
    cat /tmp/"$dockerassist_root_dir"/"$dkrstepper_dir"/"$curstep"
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