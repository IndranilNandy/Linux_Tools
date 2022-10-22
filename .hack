#!/bin/bash
# This is a hack used to support custom-setup type for a minimal server etc. In future, you may think to refactor the code.
yes | sudo ln -s -i $(pwd)/Utility_tools_setup_scripts/myinstaller/fullAptPkgTools $(pwd)/Utility_tools_setup_scripts/myinstaller/.fullAptPkgTools
yes | sudo ln -s -i $(pwd)/Utility_tools_setup_scripts/myinstaller/fullSnapPkgTools $(pwd)/Utility_tools_setup_scripts/myinstaller/.fullSnapPkgTools

for arg in "$@"; do
echo "arg=$arg"
    case $arg in
       --custom-setup=*)
        path=$(echo $arg | sed "s/--custom-setup=\(.*\)/\1/")
        echo "path=$path"
        # TODO: Add support for passing snap tools list
        [[ -z "$path" ]] || yes | sudo ln -s -i $(pwd)/Custom_setup_definitions/$path/.$path-aptpkgtools $(pwd)/Utility_tools_setup_scripts/myinstaller/.fullAptPkgTools
        [[ -z "$path" ]] || yes | sudo ln -s -i $(pwd)/Custom_setup_definitions/$path/.$path-snappkgtools $(pwd)/Utility_tools_setup_scripts/myinstaller/.fullSnapPkgTools
        ;;

    *)
        ;;
    esac
done