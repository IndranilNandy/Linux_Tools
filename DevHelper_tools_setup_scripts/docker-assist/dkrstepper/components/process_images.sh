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
