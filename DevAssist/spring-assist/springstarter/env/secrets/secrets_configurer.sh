#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

dotenv() {
    "$curDir"/env/secrets/dotenv/dotenv_configurer.sh "$@"
}

case "${1}" in
dotenv)
    dotenv "${@:2}"
    ;;
*)
    echo "--help"
    ;;
esac