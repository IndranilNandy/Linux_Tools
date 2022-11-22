#!/usr/bin/env bash

# echo -e "Running 'apt update'" | ts '[%Y-%m-%d %H:%M:%S]' >> "$(pwd)"/../cronlogs/system_update.log
# sudo apt update | ts '[%Y-%m-%d %H:%M:%S]' >> "$(pwd)"/../cronlogs/system_update.log

{
    echo -e "Running 'apt update'"
    sudo apt update
    echo -e "Completed 'apt update'"
} >> >(ts '[%Y-%m-%d %H:%M:%S]' >>"$(pwd)"/../cronlogs/system_update.log)
