#!/usr/bin/env bash

echo "Running script" | ts '[%Y-%m-%d %H:%M:%S]'
date | ts
echo "bash_source=$BASH_SOURCE"
echo "env=$(env) pwd=$(pwd)"
echo "Completed script" | ts '[%Y-%m-%d %H:%M:%S]'
echo

echo "#####################DONE#####################"
echo
echo
