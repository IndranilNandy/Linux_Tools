#!/usr/bin/env bash

userhost=
cred=
failure=0
while :; do
    read -p "Enter user@hostname: " userhost
    read -p "Password for $userhost: " -s cred
    echo -e

    sshpass -p $cred ssh -o 'StrictHostKeyChecking no' -t "$userhost" "hostname" && break || ((failure++))

    [[ "$failure" -ge 3 ]] && userhost= && cred= && break
    echo -e "Try#$failure"
done