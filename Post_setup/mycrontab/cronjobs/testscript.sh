#!/usr/bin/env bash

date | ts
echo "bash_source=$BASH_SOURCE"
echo "env=$(env) pwd=$(pwd)"
echo
