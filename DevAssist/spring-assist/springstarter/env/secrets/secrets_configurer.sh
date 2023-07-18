#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

dotenv() {
    "$curDir"/env/secrets/dotenv/dotenv_configurer.sh "$@"
}

init() {
    springstarter env secrets dotenv init "$@"
}

case "${1}" in
init)
    init "${@:2}"
    ;;
dotenv)
    dotenv "${@:2}"
    ;;
*)
    echo "--help"
    ;;
esac