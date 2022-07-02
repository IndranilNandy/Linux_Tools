#!/bin/bash

if [[ -n $1 ]] && [[ "$1" != "--help" ]]; then
    SCRIPT_PATH=$(which ${1})
    [[ ! -n $SCRIPT_PATH ]] && SCRIPT_PATH=${1}
else
    SCRIPT_PATH="${BASH_SOURCE}"
fi

SOURCE_PATH=$SCRIPT_PATH
while [ -L "${SOURCE_PATH}" ]; do
  TARGET="$(readlink "${SOURCE_PATH}")"
  if [[ "${TARGET}" == /* ]]; then
    SOURCE_PATH="$TARGET"
  else
    SOURCE_PATH="$(dirname "${SOURCE_PATH}")/${TARGET}"
  fi
done

(( "$#" == 1 )) && [[ "$1" == "--help" ]] && cat "$(dirname "${SOURCE_PATH}")"/tracelink.help && exit 0

echo "${SOURCE_PATH}"