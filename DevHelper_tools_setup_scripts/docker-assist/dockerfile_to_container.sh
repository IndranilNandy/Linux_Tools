#!/usr/bin/env bash

. ./.config-params

createContainer() {
    local basedir="${1}"
    local dockerfile="${2}"
    local image_name="${3}"
    local image_version="${4}"
    local context="${5}"
    local container_name="${6}"
    local ext=".Dockerfile"

    echo -e "docker build \
                        \n\t\t-t $image_name:$image_version \
                        \n\t\t-f $basedir/$dockerfile$ext \
                        \n\t\t$basedir/$context \n"

    echo -e "________________________________________________"

    docker build -t "${image_name}":"${image_version}" -f "${basedir}/${dockerfile}${ext}" "${basedir}/${context}"

    echo -e
    echo -e "docker run -it --name $container_name $image_name:$image_version"
    gnome-terminal --tab --title="$image_name:$image_version" -- /bin/sh -c " \
                                echo \"Dockerfile: ${dockerfile}${ext}\"; echo ; \
                                echo \"Step: ${image_version}\"; echo ; \
                                cat ${basedir}/${dockerfile}${ext}; echo ; \
                                docker run -it --name $container_name $image_name:$image_version"

    # gnome-terminal --tab --title="rails s" --tab-with-profile=Default -- /bin/sh -c "docker run -it --name $container_name $image_name:$image_version"
}

removeComments() {
    local basedir="${1}"
    local dockerfile="${2}"
    local processed_dfile="${3}"
    local ext=".Dockerfile"

    cat "$basedir"/"$dockerfile""$ext" | grep -v "^#" | grep -v "^$" >"${basedir}"/"$dockerassist_root_dir"/"$processed_dfile""$ext"
}

createIncrementalDockerfile() {
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

processIncrementalDockerfile() {
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

evaluateIncrementalDockerfile() {
    local basedir="${1}"
    local dockerfile="${2}"
    local context="${3}"
    local startline="${4}"
    local ext=".Dockerfile"

    (
        cd "${basedir}"/"$dockerassist_root_dir"/"$incr_dfiles_dir" || return 1

        local curline=$((startline))
        local image_name=i-"$dockerfile"
        local total_steps=$(ls -1 |wc -l | cut -f1 -d' ')
        local ans=c # c: current
        local step_status="changed"

        echo -e "\nTotal steps: $total_steps"

        while [ ! "$ans" = "e" ] && [ ! "$ans" = "a" ]; do
            echo -e "______________________________________________________________________________________"
            echo -e "Running step# $curline/$total_steps"
            echo -e "______________________________________________________________________________________"

            local incr_dockerfile="incr-""$curline"
            echo -e "\nProcessing $incr_dockerfile$ext:\n"
            # echo -e "total_steps=$total_steps"

            local image_version="$curline"
            local container_name=c-"$dockerfile"-"$image_version"

            case "$step_status" in
                changed)
                    echo -e "changed"
                    ;;
                unchanged)
                    echo -e "unchanged"
                    ;;
                error)
                    echo -e "error occurred"
                    ;;
            esac

            # processIncrementalDockerfile "$basedir" "$incr_dockerfile" "$image_name" "$image_version" "$context" "$container_name"

            echo -e
            echo -e "Current step# $curline/$total_steps"
            read -p "n[next] or p[prev] or line#[e.g. 12] or s[skip] or a[abort] or e[exit] " ans

            case $ans in
            n)
                ((curline < total_steps)) && ((curline++)) && step_status="changed" || step_status="unchanged"
                ;;
            p)
                ((curline > 1)) && ((curline--)) && step_status="changed" || step_status="unchanged"
                ;;
            ([[:digit:]]*)
                echo "digit"
                ((ans <= total_steps)) && ((curline=ans)) && step_status="changed" || step_status="unchanged"
                ;;
            s)
                ;;
            a)
                step_status="aborted"
                ;;
            e)
                step_status="exited"
                ;;
            *) ;;

            esac

        done
    )
}

basedir1="$HOME/DEV/GIT-REPOS/PracticeWS/IDEwise/Vscode/Java/javatest2/app"
dockerfile1=javatest2-sample1
image_name1="testimage"
image_version1="1"
context1=.
container_name1="test_container"
startline1=1

# createIncrementalDockerfile "$basedir" "$dockerfile" "$processed_dfile" || echo -e "Cannot create incremental dockerfiles"
createIncrementalDockerfile "$basedir1" "$dockerfile1" || echo -e "Cannot create incremental dockerfiles"

evaluateIncrementalDockerfile "$basedir1" "$dockerfile1" "$context1" "$startline1"
# createContainer "$basedir" "$dockerfile" "$image_name" "$image_version" "$context" "$container_name"
