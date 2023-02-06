#!/usr/bin/env bash

if [ -L "$(which dfdebugger)" ]; then
    curDir="$(dirname "$(tracelink dfdebugger)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/components/process_runinfo.sh

# Default: stopped. Other valid values: all
run_type="stopped"

# Default: all. Other valid values: containers, images
rs_type="all"

clean_config=

for arg in "$@"; do
    case "$arg" in
    --force)
        run_type="all"
        ;;
    --containers)
        if [[ "$rs_type" == "all" ]]; then
            rs_type="containers"
        else
            rs_type="all"
        fi
        ;;
    --images)
        if [[ "$rs_type" == "all" ]]; then
            rs_type="images"
        else
            rs_type="all"
        fi
        ;;
    --config)
        rs_type="configs"
        clean_config="yes"
        ;;
    esac
done

echo "run_type = $run_type" "rs_type = $rs_type"
cleanRun "$run_type" "$rs_type"
([[ "$clean_config" == "yes" ]] || [[ "$rs_type" == "all" ]]) && cleanConfig
