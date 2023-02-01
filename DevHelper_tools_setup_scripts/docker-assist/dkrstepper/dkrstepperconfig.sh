#!/usr/bin/env bash
for arg in "$@"; do
    case $arg in
    --options)
        echo -e "You've chosen to add extra options!"
        echo -e "[NOTE] You cannot change/remove the default options, only add extra options to docker 'build' and 'run' commands.\n"
        echo -e "Enter options for the 'docker build' command on a single line [Default: -t <image-name>:<image-version> -f <dockerfile>]:"
        echo -e "Current (extra) build options: $DKRSTEPPER_BUILD_OPTIONS"
        read -r -p "[ Press ENTER to accept defaults + existing extra options] > " buildoptions
        export DKRSTEPPER_BUILD_OPTIONS=${buildoptions:-"$DKRSTEPPER_BUILD_OPTIONS"}

        echo -e "Enter options for the 'docker run' command on a single line [Default: --name <container-name>]:"
        echo -e "Current (extra) run options: $DKRSTEPPER_RUN_OPTIONS"
        read -r -p "[ Press ENTER to accept defaults + existing extra options] > " runoptions
        export DKRSTEPPER_RUN_OPTIONS=${runoptions:-"$DKRSTEPPER_RUN_OPTIONS"}
        ;;
    --options-reset)
        export DKRSTEPPER_BUILD_OPTIONS=
        export DKRSTEPPER_RUN_OPTIONS=
        echo -e "Docker build options have been reset to the defaults"
        echo -e "Docker run options have been reset to the defaults"
        ;;
    --options-reset=build)
        export DKRSTEPPER_BUILD_OPTIONS=
        echo -e "Docker build options have been reset to the defaults"
        ;;
    --options-reset=run)
        export DKRSTEPPER_RUN_OPTIONS=
        echo -e "Docker run options have been reset to the defaults"
        ;;
    *)
        echo -e "INVALID ARGUMENTS!"
        ;;
    esac
done