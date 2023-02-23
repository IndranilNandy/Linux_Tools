#!/usr/bin/env bash

curDir="$(pwd)"

case "${1}" in
add)
    "$curDir"/scripts/add_env.sh "${@:2}"
    ;;
remove)
    "$curDir"/scripts/delete_env.sh "${@:2}"
    ;;
--help)
    cat "$curDir"/myshpath.help
    ;;
*)
    cat "$curDir"/myshpath.help
    ;;
esac
