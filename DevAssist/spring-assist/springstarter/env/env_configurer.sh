#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

secrets() {
    "$curDir"/env/secrets/secrets_configurer.sh "$@"
}

case "${1}" in
secrets)
    secrets "${@:2}"
    ;;
*)
    echo "--help"
    ;;
esac