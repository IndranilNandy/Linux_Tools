#!/bin/bash

if [[ -L $(which code-ext) ]]; then
    curDir="$(dirname "$(tracelink code-ext)")"
else
    curDir="$(pwd)/extensions"
fi

refresh_ext_list() {
    cat $curDir/.extensions | grep "$1" || echo -e "\n$1" >> $curDir/.extensions
}
export -f refresh_ext_list
export curDir

# code --list-extensions | xargs -I EXT bash -c "refresh_ext_list EXT"

case $1 in 
    --refresh)
        code --list-extensions | xargs -I EXT bash -c "refresh_ext_list EXT"
        ;;
    --update)
        $curDir/all_extensions_installer.sh
        ;;
    --list)
        cat $curDir/.extensions
        ;;
    --help)
        cat $curDir/../help/code-ext.help
        ;;
    *)
        cat $curDir/../help/code-ext.help
        ;;
esac

