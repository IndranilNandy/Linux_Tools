#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

springio_url="https://start.spring.io/#!"
tmpdir="/tmp/springstarter/project"
project_info="$tmpdir"/config/project_metadata/.project.info
project_dependencies="$tmpdir"/config/project_metadata/.dependencies

############################################################################################################################
# USAGE: COPY THIS SCRIPT TO THE LOCATION WHERE YOU WANT TO CREATE THE SPRING PROJECT, AND CHANGE THE PARAMETERS ACCORDINGLY

# To check supported dependencies -> spring init --list -> shows service capabilities
############################################################################################################################
# Default: package-name=groupId.artifact-id (if package-name NOT PROVIDED)
# If package-name is EXPLICITY provided, then it'll be taken as the package name ignoring the above one
# Your application entrypoint file will be created in this package

# Default: artifact-id = location (if artifact-id NOT PROVIDED) <<spring init [options] [location]>>
# If artifact-id is EXPLICITY provided, then -it'll be taken as artifact-id ignoring location
# (in settings.gradle) rootProject.name = artifact-id

# Default: Only demo.zip is created (if location NOT PROVIDED) <<spring init [options] [location]>>
# If location is provided, the the project will be created in ./<location>/

# Default: --name option provides the name of the main application under the <package> which would be '<name>Application'
# if --name NOT PROVIDED, then the main application name would be DemoApplication, by default
############################################################################################################################

# We are not providing package-name, using the default one
# Default: package-name=groupId.artifact-id (if package-name NOT PROVIDED)

create_tmp_setup() {
    mkdir -p "$tmpdir"
    cp -r "$LINUX_TOOLS_project_config" "$tmpdir"
    code -w "$project_info"
    code -w "$project_dependencies"/*.dependencies
}

configure_project() {
    local project_name="${1}"
    (
        cd "$(pwd)/$project_name" || exit 1
        mkdir -p ".setup"
        cp -r "$tmpdir"/config .setup

        springstarter env secrets dotenv load
        springstarter db postgresql container init
    )
}

gen_project_with_springio() {
    local localdir="$(pwd)"
    local project_name="${1}"
    local project_info_url=$(cat "$project_info" | grep -v " *#" | grep -v "^$" | tr '\n' '&')
    local all_dependencies=$(cat "$project_dependencies"/*.dependencies | grep -v " *#" | grep -v "^$" | tr '\n' ',')
    all_dependencies="${all_dependencies::-1}" # Removing last character ','
    local project_url="$springio_url""$project_info_url"dependencies="$all_dependencies"

    echo -e "\nFirst, generating and downloading the project from spring.io, once you download, close the browser."
    sleep 1
    echo -e "Loading project url: $project_url"

    xdg-open "$project_url" >/dev/null 2>&1
    echo -e
    read -p "Did you download the generated project? [y/n] .." ans

    [[ "$(echo $ans | tr [:upper:] [:lower:])" == "n" ]] && return 1

    new_file=$(ls -1t "$HOME"/Downloads | grep "$project_name" | head -n1)
    mv "$HOME"/Downloads/"$new_file" "$tmpdir"
    (
        cd "$tmpdir"
        unzip "$new_file"
        mv "$project_name" "$localdir"
    )
    echo "Project created and downloaded in $localdir"

    (
        cd "$(pwd)/$project_name" || exit 1
        mkdir -p ".setup"
        cp -r "$tmpdir"/config .setup

        # springstarter env secrets dotenv load
        # springstarter db postgresql container init
    )

    return 0
}

clean_tmp_setup() {
    rm -rf "$tmpdir"
}

create_project() {
    create_tmp_setup

    local project_name=$(awk -F'=' '$1 == "name" {print $2}' "$project_info")
    gen_project_with_springio "$project_name" || return 1
    configure_project "$project_name" || return 1

    clean_tmp_setup
}

create() {
    create_tmp_setup

    project_name=$(awk -F'=' '$1 == "name" {print $2}' "$project_info")

    [[ -d "$(pwd)/$project_name" ]] && echo -e "Project with this name already exists. Exiting without creating a new project" && return 1
    gen_project_with_springio "$project_name" || return 1
    # configure_project "$project_name" || return 1

    # clean_tmp_setup
}

prompt() {
    subcommands="$curDir"/project/.commands

    cat "$subcommands" | nl
    read -p "Your choice: " no

    local choice=$(cat "$subcommands" | nl | head -n"$no" | tail -n1 | cut -f2)
    echo "Selected: $choice"

    "${0}" "$choice"
}

project_name=
case "${1}" in
init)
    springstarter project create "${@:2}"

    # Since, in this case, 'create' and 'config' will be called consecutively,
    # "$tmpdir"/config/project_metadata/.project.info wouldn't be changed, in between, by any other command (not running parallely)
    project_name=$(awk -F'=' '$1 == "name" {print $2}' "$project_info")
    springstarter project config "$project_name"
    ;;
create)
    create "${@:2}" || exit 1
    project_name=$(awk -F'=' '$1 == "name" {print $2}' "$project_info")
    echo -e "PROJECT NAME = $project_name"
    ;;
config)
    project_name="${@:2}"
    [[ -z "$project_name" ]] && echo -e "Project name not provided. Exiting" && exit 1
    [[ ! -d "$(pwd)/$project_name" ]] && echo -e "Not able to find the project directory in the current directory. Exiting." && exit 1
    (
        cd "$(pwd)/$project_name" || exit 1
        springstarter config init "${@:2}"
    )
    ;;
help)
    echo --help
    ;;
'')
    prompt
    ;;
*) ;;
esac
