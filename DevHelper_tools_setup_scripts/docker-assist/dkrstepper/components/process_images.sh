#!/usr/bin/env bash

cleanImages() {
    local dockerfile="${1}"
    local -n version_set_ref=${2}
    local session_id="${3}"

    echo -e "______________________________________________________________________________________"
    echo -e "CLEANING IMAGES"
    echo -e "______________________________________________________________________________________"

    for version in "${!version_set_ref[@]}"; do
        local image_name=$(echo i-"$dockerfile"-"$session_id":"$version" | tr [:upper:] [:lower:])
        echo -e "Removing image: $image_name" && docker image rm "$image_name" && echo -e "Removed image: $image_name\n" || echo -e "Error in removing image $image_name\n"
    done
}

cleanImage() {
    local image_name="${1}"
    echo -e "Removing image: $image_name" && docker image rm "$image_name" && echo -e "Removed image: $image_name\n" || echo -e "Error in removing image $image_name\n"

}

clean_all_session_images() {
    local run_id="${1}"

    dkr_dir=/tmp/"$dockerassist_root_dir"/"$rundata_dir"
    sessions_file="$dkr_dir"/"$run_id"/"$all_sessions_file"
    export -f cleanImage

    echo -e "______________________________________________________________________________________"
    echo -e "CLEANING ALL SESSION IMAGES" [Run id: "$run_id"]
    echo -e "______________________________________________________________________________________"

    cat "$sessions_file" | xargs -I X echo "[[ -e $dkr_dir/$run_id/$sessions_dir/X/$session_images ]] && cat $dkr_dir/$run_id/$sessions_dir/X/$session_images" | bash | xargs -I X echo "cleanImage X" | bash
    cat "$sessions_file" | xargs -I X echo "[[ -e $dkr_dir/$run_id/$sessions_dir/X/$session_images ]] && rm $dkr_dir/$run_id/$sessions_dir/X/$session_images || echo -e Session id - X: Already cleaned" | bash
}
