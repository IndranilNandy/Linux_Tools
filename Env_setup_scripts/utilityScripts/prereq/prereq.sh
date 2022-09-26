#!/bin/bash

if [[ -z $(which prereq) ]]; then
    helpDir=$(pwd)
else
    helpDir=$(dirname "$(tracelink "$(which prereq)")")
fi

process_exceptionlist() {
    for dep in $(cat "$helpDir"/.exceptionlist | grep -f "${1}" | xargs -n1); do
        case "$dep" in
        sdkman)
            verification_script=' source ~/.bashrc; \
sdk version >> /dev/null 2>&1 || exit 1; \
exit 0 '

            bash --init-file <(echo "$verification_script;") || echo "$dep"
            ;;
        *) ;;

        esac
    done
}

missing_prereqs() {
    prereqfile=${1}
    process_exceptionlist "$prereqfile"

    missing=$(
        cat $prereqfile | grep -v -f "$helpDir"/.exceptionlist |
            xargs -I XYZ echo "[[ ! \$(apt --installed list 2> /dev/null | grep XYZ) && ! \$(which XYZ) ]] && echo 'XYZ'" |
            bash
    )

    echo "$missing"
}

case ${1} in
--install)
    export ToolsDir="$HOME/MyTools/Linux_Tools"
    missing_prereqs ${2} | xargs -I FILE find "$ToolsDir" -name FILE | xargs -I INPUT echo "(cd INPUT && pwd && find . -name .setup | bash)" | bash
    missing_prereqs ${2} | xargs -I TOOL myinstaller --install TOOL
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
