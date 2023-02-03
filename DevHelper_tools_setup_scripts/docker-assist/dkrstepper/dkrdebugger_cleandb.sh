#!/usr/bin/env bash

if [ -L "$(which dkrdebugger)" ]; then
    curDir="$(dirname "$(tracelink dkrdebugger)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/components/process_runinfo.sh

# Default: stopped. Other valid values: all
run_type="stopped"

# Default: all. Other valid values: containers, images
rs_type="all"

for arg in "$@"; do
    case "$arg" in
    --allruns)
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
    esac
done

cleanRun "$run_type" "$rs_type"