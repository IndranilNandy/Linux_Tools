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

# For packages in .exceptionlist we cannot use subshell, these packages only work in interactive terminal which can be simulated with bash --init-file
install_from_exceptionlist() {
    pkg=${1}

    ex_dir=$(pwd)
    cd "$pkg"
    exp=" $pkg/.setup"
    bash --init-file <(echo -e "$exp; exit;")
    cd "$ex_dir"
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

export -f install_from_exceptionlist

case ${1} in
--install)
    export ToolsDir="$HOME/MyTools/Linux_Tools"
    missing_prereqs ${2} | grep -v -f "$helpDir"/.exceptionlist | xargs -I FILE find "$ToolsDir" -name FILE | xargs -I INPUT echo "(cd INPUT && pwd && find . -name .setup | bash)" | bash
    missing_prereqs ${2} | grep -v -f "$helpDir"/.exceptionlist | xargs -I TOOL myinstaller --install TOOL
    for exc_pkg in $(missing_prereqs ${2} | grep -f "$helpDir"/.exceptionlist | xargs -I FILE find "$ToolsDir" -name FILE); do
        install_from_exceptionlist "$exc_pkg"
    done
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
