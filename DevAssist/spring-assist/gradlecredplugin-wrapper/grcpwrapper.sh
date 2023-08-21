#!/usr/bin/env bash

if [ -L $(which grcpwrapper) ]; then
    curDir="$(dirname "$(tracelink grcpwrapper)")"
else
    curDir="$(pwd)"
fi

credparams="$curDir"/.credparams
credparams_temp="$curDir"/.credparams-temp

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
    local passphrase=
    local location=default
    local ifphraseused="no"

    [[ ! -f "$curDir"/build.gradle ]] && echo "build.gradle doesn't exist in current directory (should be run from project root directory), hence exiting." && return 1

    for arg in "${@}"; do
        case "$arg" in
        -p)
            echo -e "[WARNING!] Ensure you're using the same passphrase as the last run"
            echo -e "Enter custom passphrase for storing credentials. Do you want to show the passphrase on screen?"
            read -rp "[y/n] --> " res
            res=$(echo "$res" | tr [:upper:] [:lower:])
            ifphraseused="yes"

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

    if [[ -f "$credparams" ]]; then
        existing_location=$(grep "Location:" "$credparams" | sed "s/# Location: \(.*\)/\1/")
        if [[ ! "$existing_location" == "$location" ]]; then
            echo -e "You are not using the same location to store credentials as in the last run.\nEither delete existing "$credparams" and enter all parameters afresh, or provide the last location: $existing_location"
            return 1
        fi

        existing_phrase=$(grep "Passphrase used" "$credparams" | sed "s/# Passphrase used: \(.*\)/\1/")
        if [[ ! "$existing_phrase" == "$ifphraseused" ]]; then
            echo -e "You cannot change your passphrase from the last run"
            return 1;
        fi
    fi

    echo -e "Enter the credential parameters one by one in $credparams_temp opened in editor. Save and Exit."

    [[ -f "$credparams_temp" ]] && echo -e "$credparams_temp exists. The last successful run should have deleted this. Deleting it." && rm "$credparams_temp"
    echo -e "# Enter each \"NEW\" credential parameter on a single line. Do not enter the values.\n# Sample:\n# Param1\n" >>"$credparams_temp"
    code -w "$credparams_temp"

    [[ -f "$credparams" ]] || echo -e "# This is the list of already existing encrypted credential parameters\n# Location: $location\n# Passphrase used: $ifphraseused" >>"$credparams"

    echo -e "Enter each credential's value one by one on the command-line. Do you want to show the credential-value on screen?"
    read -rp "[y/n] --> " res
    res=$(echo "$res" | tr [:upper:] [:lower:])

    for param in $(cat "$credparams_temp" | grep -v "^$" | grep -v " *#"); do
        ifexists="no"
        grep -q "^$param$" "$credparams" && ifexists="yes" && read -rp "$param: Parameter exists. Do you want to override? [y/n].. " rep
        rep=$(echo "$rep" | tr [:upper:] [:lower:])

        if [[ "$ifexists" == "no" || "$rep" == "y" ]]; then
            [[ "$res" == "n" ]] && read -rp "$param -> " -s paramvalue || read -rp "$param -> " paramvalue
            echo -e
            # gradleAddCreds "$param" "$paramvalue" "$passphrase" "$location" || return 1
            [[ "$ifexists" == "no" ]] && echo "$param" >>"$credparams"
        fi
    done

    rm "$credparams_temp"
    return 0
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
