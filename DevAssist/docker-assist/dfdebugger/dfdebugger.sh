#!/usr/bin/env bash

if [ -L "$(which dfdebugger)" ]; then
    curDir="$(dirname "$(tracelink dfdebugger)")"
else
    curDir="$(pwd)"
fi

case "${1}" in
step)
    "$curDir"/dfstepper.sh "${@:2}"
    ;;
clean)
    "$curDir"/dfdebugger_cleandb.sh "${@:2}"
    ;;
show)
    "$curDir"/dfstepper.sh "${@:2}"
    ;;
*)
    "$curDir"/dfstepper.sh "$@"
    ;;
esac
