#!/bin/bash

missing_prereqs() {
    prereqfile=${1}

    missing=$(
        cat $prereqfile | 
    xargs -I XYZ echo "[[ ! \$(apt --installed list 2> /dev/null | grep XYZ) && ! \$(which XYZ) ]] && echo 'XYZ'" | 
    bash
    )

    echo "$missing"
}

if [[ -z $(which prereq) ]]; then
    helpDir=$(pwd)
else
    helpDir=$(dirname "$(tracelink "$(which prereq)")")
fi

case ${1} in
    --install)
        export ToolsDir="$HOME/MyTools/Linux_Tools"
        missing_prereqs ${2} | xargs -I FILE find "$ToolsDir" -name FILE | xargs -I INPUT echo "(cd INPUT && pwd && find . -name .setup | bash)" | bash
        ;;
    --missing)
        missing_prereqs ${2}
        ;;
    --missingcount)
        missing_prereqs ${2} | wc -l
        ;;
    --list)
        cat ${2}
        ;;
    --help)
        cat $helpDir/prereq.help
        ;;
    *)
        cat $helpDir/prereq.help
        ;;
esac