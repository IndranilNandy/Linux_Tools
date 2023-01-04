#!/bin/bash

if [[ -z $(which ifinstalled) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which ifinstalled)")")
fi

case ${1} in
    --list)
        echo "Tools installed with APT package manager:"
        sudo apt list --installed
        echo -e "\nCustom symbolic links available:"
        sudo ls $MYCOMMANDSREPO
        ;;
    --apt)
        echo "Tools installed with APT package manager:"
        sudo apt list --installed
        ;;
    --snap)
        echo "Tools installed with SNAP package manager:"
        sudo snap list
        ;;
    --link)
        echo -e "\nCustom symbolic links available:"
        sudo ls $MYCOMMANDSREPO
        ;;
    --help)
        cat $curDir/ifinstalled.help
        ;;
    "")
        cat $curDir/ifinstalled.help
        ;;
    *)
        # xargs -I X echo "eval \$(echo \"echo \\\"X\\\" | tr -s ' ' | cut -f2- -d' '\" | bash)" < "$curDir"/.explicit_checks | bash
        # All tools which require special handling to check if it is installed, will have an entry in .explicit_checks in this format - <tool_name>\t<command_to_check>
        if [[ $(gawk -v com="${1}" '$1==com {print $NL}' "$curDir"/.explicit_checks) ]]; then
            gawk -v com="${1}" '$1==com {print $NL}' "$curDir"/.explicit_checks | xargs -I X echo "eval \$(echo \"echo \\\"X\\\" | tr -s ' ' | cut -f2- -d' '\" | bash)" | bash
        else
            which "${1}" || (sudo apt list --installed 2> /dev/null | grep "${1}") || (sudo snap list 2> /dev/null | grep "${1}") || (sudo npm ls -g "${1}" | awk 'NR==2' | grep "${1}")
        fi
        ;;
esac