#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

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

create_project() {
    spring init \
        --boot-version=3.1.1 \
        --build=gradle \
        --type=gradle-project \
        --java-version=17 \
        --packaging=jar \
        --name=product-service \
        --groupId=com.mydomain.core \
        --artifact-id=product \
        --dependencies=actuator,configuration-processor,data-jpa,devtools,h2,lombok,mysql,postgresql,validation,web \
        --version=1.0.0-SNAPSHOT \
        "${1}"

    (
        cd "$(pwd)/${1}" || exit 1
        springstarter env secrets dotenv load
        springstarter db postgresql container init
    )
}

create_project "${@}"

# case "${1}" in
# project)
#     create_project "${@:2}"
#     ;;
# db)
#     "$curDir"/db/db_configurer.sh "${@:2}"
#     ;;
# env)
#     "$curDir"/env/env_configurer.sh "${@:2}"
#     ;;
# *)
#     echo "--help"
#     ;;
# esac
