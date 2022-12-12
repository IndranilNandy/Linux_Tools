#!/usr/bin/env bash

if [ -L $(which springstarter) ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/buildfile_parser.sh

tmpdir="tmp"

get_project_url() {
    echo "$(extract_project_url)"
}

get_local_build_file() {
    echo "$(pwd)/build.gradle"
}

get_downloaded_build_file() {
    echo "$(pwd)"/"$(find $tmpdir -name "build.gradle")"
}

fetch_project() {
    echo -e "\nFirst, generating and downloading the project from spring.io, once you download, close the browser."
    sleep 1
    echo -e "Loading project url: ${1}"

    xdg-open "${1}" >/dev/null 2>&1
    echo -e
    read -p "Did you download the generated project? [y/n] .." ans

    [[ "$(echo $ans | tr [:upper:] [:lower:])" == "n" ]] && return 1

    mkdir "$tmpdir"
    new_file=$(ls -1t "$HOME"/Downloads | grep demo | head -n1)
    mv "$HOME"/Downloads/"$new_file" "$tmpdir"
    (
        cd "$tmpdir"
        unzip "$new_file"
    )
    echo "Downloaded project unzipped to $(pwd)/$tmpdir"
}

merge_build_files() {
    echo -e "\nMerging files:\n${1}\n${2}"
    p4merge -nb "Ignore this file as base!" -nl "Current Build File" -nr "Downloaded Build File" -nm "Merged Build File" "${1}" "${1}" "${2}" "${1}" 2> /dev/null
    echo -e "\nMerged into:\n${1}"
}

clean() {
    rm -rf "$tmpdir"
    echo -e "\nRemoved temporary files and directories: $(pwd)/$tmpdir"
}

add_starter() {
    [[ ! -f build.gradle ]] && echo "build.gradle doesn't exist in current directory, hence exiting." && return 0

    fetch_project "$(get_project_url)" && merge_build_files "$(get_local_build_file)" "$(get_downloaded_build_file)" && clean || return 1
}

echo -e "Only followings are supported:"
echo -e "Project type: Gradle - Groovy"
echo -e "Language: Java"
add_starter || echo -e "ABORTED!!!"
