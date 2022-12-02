#!/usr/bin/env bash

# Source this loader file for any job which requires access to bash functions defined in .bashrc.
# Since we cannot directly include .bashrc, as it has a check for non-interactive shell. Either we have to disable that check,
# or put our required functionality explicitly in another script and source that scritpt. This is what we are doing here.

source $(dirname "$BASH_SOURCE")/jobhelpers/envloader.sh

echo "Running script" | ts '[%Y-%m-%d %H:%M:%S]'
echo "Deleting all logs"
mycrontab --clean-logs
echo "Deleted all logs"
echo "Completed script." | ts '[%Y-%m-%d %H:%M:%S]'

echo "#####################DONE#####################"
echo