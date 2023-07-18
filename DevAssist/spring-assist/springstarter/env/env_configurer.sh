#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

secrets() {
    "$curDir"/env/secrets/secrets_configurer.sh "$@"
}

init() {
    springstarter env secrets init "${@}"
}

case "${1}" in
init)
    init "${@:2}"
    ;;
secrets)
    secrets "${@:2}"
    ;;
*)
    echo "--help"
    ;;
esac
