#!/usr/bin/env bash

if [ -L $(which grcpwrapper) ]; then
    curDir="$(dirname "$(tracelink grcpwrapper)")"
else
    curDir="$(pwd)"
fi

gradleAddCreds() {
    local key="${1}"
    local value="${2}"
    local passphrase="${3}"
    local location="${4}"

    [[ -z "$passphrase" ]] && [[ -z "$location" ]] && gradle addCredentials --key "$key" --value "$value" && return 0
    [[ -z "$passphrase" ]] && gradle addCredentials --key "$key" --value "$value" -PcredentialsLocation="$location" && return 0
    [[ -z "$location" ]] && gradle addCredentials --key "$key" --value "$value" -PcredentialsPassphrase="$passphrase" && return 0
    gradle addCredentials --key "$key" --value "$value" -PcredentialsPassphrase="$passphrase" -PcredentialsLocation="$location" && return 0
    return 1
}

addCreds() {
    local credparams="$curDir"/.credparams
    local passphrase=
    local location=

    [[ ! -f "$curDir"/build.gradle ]] && echo "build.gradle doesn't exist in current directory (should be run from project root directory), hence exiting." && return 1

    for arg in "${@}"; do
        case "$arg" in
        -p)
            echo -e "Enter custom passphrase for storing credentials. Do you want to show the passphrase on screen?"
            read -rp "[y/n] --> " res
            res=$(echo "$res" | tr [:upper:] [:lower:])

            [[ "$res" == "n" ]] && read -rp "Enter passphrase: " -s passphrase || read -rp "Enter passphrase: " passphrase
            ;;
        -l)
            read -rp "Enter custom directory location of the credentials file: " location
            if [[ ! -d "$location" ]]; then
                ! mkdir -p "$location" && echo -e "Invalid location to create!" && return 1
            fi
            ;;
        *) ;;
        esac
    done
    # return 0

    echo -e "Enter the credential parameters one by one in $credparams opened in editor. Save and Exit."
    [[ ! -f "$credparams" ]] && echo -e "# Enter each parameter on a single line. Do not enter the values.\n# Sample:\n# Param1\n" >>"$credparams"
    code -w "$credparams"

    echo -e "Now you'll enter each credential's value one by one on the command-line. Do you want to show the password on screen?"
    read -rp "[y/n] --> " res
    res=$(echo "$res" | tr [:upper:] [:lower:])

    for param in $(cat "$credparams" | grep -v "^$" | grep -v " *#"); do
        [[ "$res" == "n" ]] && read -rp "$param -> " -s paramvalue || read -rp "$param -> " paramvalue
        echo -e
        gradleAddCreds "$param" "$paramvalue" "$passphrase" "$location" || return 1
    done

    return 0;
}

case "${1}" in
add)
    addCreds "${@:2}" || echo -e "addCredentials: Failed!"
    ;;
remove)
    removeCreds "${@:2}" || echo -e "removeCredentials: Failed!"
    ;;
help)
    help
    ;;
'')
    prompt
    ;;
*)
    help
    ;;
esac
