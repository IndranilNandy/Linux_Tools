#!/usr/bin/env bash

createContainer() {
    local basedir="${1}"
    local dockerfile="${2}"
    local image_name="${3}"
    local image_version="${4}"
    local context="${5}"
    local container_name="${6}"
    local ext=".Dockerfile"

    if [[ "$DKRSTEPPER_BUILD_OPTIONS" ]]; then
        DOCKER_BUILDKIT=1 docker build "$DKRSTEPPER_BUILD_OPTIONS" -t "${image_name}":"${image_version}" -f "${basedir}/${dockerfile}${ext}" "${basedir}/${context}"
    else
        DOCKER_BUILDKIT=1 docker build -t "${image_name}":"${image_version}" -f "${basedir}/${dockerfile}${ext}" "${basedir}/${context}"
    fi

    if [[ "$DKRSTEPPER_RUN_OPTIONS" ]]; then
        runcommand="docker run -it $DKRSTEPPER_RUN_OPTIONS --name $container_name $image_name:$image_version"
    else
        runcommand="docker run -it --name $container_name $image_name:$image_version"
    fi

    echo -e "Build command:"
    echo -e "DOCKER_BUILDKIT=1 docker build $DKRSTEPPER_BUILD_OPTIONS\
                        \n\t\t-t $image_name:$image_version \
                        \n\t\t-f $basedir/$dockerfile$ext \
                        \n\t\t$basedir/$context \n"

    echo -e "________________________________________________"

    echo -e "Run command:"
    echo -e "$runcommand"

    gnome-terminal --tab --title="$image_name:$image_version" -- /bin/sh -c " \
                                echo \"Dockerfile: ${dockerfile}${ext}\"; echo ; \
                                echo \"Step: ${image_version}\"; echo ; \
                                cat ${basedir}/${dockerfile}${ext}; echo ; \
                                $runcommand"
}

cleanContainers() {
    local dockerfile="${1}"
    local -n version_set_ref=${2}

    echo -e "______________________________________________________________________________________"
    echo -e "CLEANING CONTAINERS"
    echo -e "______________________________________________________________________________________"

    for version in "${!version_set_ref[@]}"; do
        local container_name=$(echo c-"$dockerfile"-"$version" | tr [:upper:] [:lower:])
        echo -e "Removing container: $container_name" && docker stop "$container_name" && docker rm "$container_name" && echo -e "Removed container: $container_name\n" || echo -e "Error in removing container $container_name\n"
    done
}
