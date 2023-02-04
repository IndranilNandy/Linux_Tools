#!/usr/bin/env bash

if [ -L "$(which dkrdebugger)" ]; then
    curDir="$(dirname "$(tracelink dkrdebugger)")"
else
    curDir="$(pwd)"
fi

case "${1}" in
step)
    "$curDir"/dkrstepper.sh "${@:2}"
    ;;
clean)
    "$curDir"/dkrdebugger_cleandb.sh "${@:2}"
    ;;
*)
    "$curDir"/dkrstepper.sh "$@"
    ;;
esac
