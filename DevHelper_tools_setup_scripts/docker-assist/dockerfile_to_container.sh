#!/usr/bin/env bash

. ./.config-params

createContainer() {
    local basedir="${1}"
    local local local dockerfile="${2}"
    local image_name="${3}"
    local image_version="${4}"
    local context="${5}"
    local container_name="${6}"
    local ext=".Dockerfile"

    docker build -t "${image_name}":"${image_version}" -f "${basedir}/${dockerfile}${ext}" "${basedir}/${context}"
    docker run --rm -it --name "${container_name}" "${image_name}":"${image_version}"
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

evaluateIncrementalDockerfile() {
    local basedir="${1}"
    local dockerfile="${2}"
    local context="${3}"
    local startline="${4}"
    local ext=".Dockerfile"

    (
        cd "${basedir}"/"$dockerassist_root_dir"/"$incr_dfiles_dir" || return 1
        stages=$(ls | wc -l)

        local curline=$((startline))
        ans=c # c: current

        while [ ! "$ans" = "e" ]; do
            # echo "ans=$ans"
            local incr_dockerfile="incr-""$curline"
            echo -e "Processing $incr_dockerfile$ext:\n"
            cat incr-"$curline""$ext"
            echo -e

            local image_name=i-"$dockerfile"
            local image_version="$curline"
            local container_name=c-"$dockerfile"-"$image_version"

            echo -e "$basedir"/"$dockerassist_root_dir"/"$incr_dfiles_dir" "$incr_dockerfile" "$image_name" "$image_version" "$context" "$container_name"

            createContainer "$basedir"/"$dockerassist_root_dir"/"$incr_dfiles_dir" "$incr_dockerfile" "$image_name" "$image_version" "../../""$context" "$container_name"

            read -p "n [next] or p [prev] or e [exit] " ans

            case $ans in
            n)
                ((curline++))
                ;;
            p)
                ((curline--))
                ;;
            *) ;;

            esac

        done

        # for ((i = 1; i <= stages; i++)); do
        #     echo "stage$i"
        # done
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
