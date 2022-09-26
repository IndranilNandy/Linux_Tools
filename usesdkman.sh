#!/bin/bash

# default values
installationType="(min|default)"
loggingDest="/dev/stdout"
errorDest="/dev/stdout"
cust_setup_def="No custom setup defined"

set_instType() {
    case ${1} in
    min)
        installationType="min"
        ;;
    default)
        installationType="(min|default)"
        ;;
    dev)
        installationType="(min|default|dev)"
        ;;
    full)
        installationType="min|default|dev|full"
        ;;
    *)
        exit 1
        ;;
    esac
}

set_logDest() {
    case ${1} in
    file)
        loggingDest=".logs"
        errorDest=".errors"
        ;;
    term)
        loggingDest="/dev/stdout"
        errorDest="/dev/stdout"
        ;;
    *) ;;

    esac
}

for arg in "$@"; do
    case $arg in
    --type=*)
        # options default, dev, full, minimal
        set_instType $(echo $arg | sed "s/--type=\(.*\)/\1/")
        ;;

    --log-target=*)
        #options file, term
        set_logDest $(echo $arg | sed "s/--log-target=\(.*\)/\1/")
        ;;

    --custom-setup=*)
        path=$(echo $arg | sed "s/--custom-setup=\(.*\)/\1/")
        [[ -n "$path" ]] && cust_setup_def=$(cat ../Custom_setup_definitions/$path/.$path)
        ;;

    *)
        echo "invalid arguments" && exit 1
        ;;
    esac
done

filter_tools() {
    # xargs -I X echo "grep -E -q \"\$(basename \$(dirname X)).*${1}.*\" ./install.config && echo X" | bash
    xargs -I X echo "grep -E -q \"\$(basename \$(dirname X)).*${1}.*\" $(echo $(pwd)/**/install.config) && echo X" | bash
}

export loggingDest
export errorDest

echo -e "\n${YELLOW}${BOLD}[Using SDKMAN installer] [$(pwd)] Starting setup.${RESET}"

sdkpkgs=$(pwd)/.sdkmanpkgs
ex_dir=$(pwd)

for pkg in $(echo $(pwd)/**/**/.* | xargs -n1 echo | grep '\.setup' | grep -E -v "$cust_setup_def" | grep -E -f "$sdkpkgs" | filter_tools \$installationType | xargs -I X echo X); do
    cd $(dirname "$pkg")
    # TODO: 2>> >(ts '[%Y-%m-%d %H:%M:%S]' >> \"\$errorDest\"
    exp=" $pkg >> >(ts '[%Y-%m-%d %H:%M:%S]' >> \"\$loggingDest\");"
    bash --init-file <(echo -e "$exp exit;")
    cd "$ex_dir"
done



echo -e "\n${GREEN}${BOLD}[Using SDKMAN installer] [$(pwd)] Setup completed.${RESET}"
echo
