#!/usr/bin/env bash

javahome=$(update-alternatives --list java | grep "java-18-openjdk-amd64" | head -n1 | sed "s#\(.*\)/bin/java#\1#")
path="$javahome/bin"

expHome="export JAVA_HOME=$javahome"
expPath="export PATH=$PATH:$path"

if [[ $( cat ~/.bashrc | grep "$expHome") ]]; then
    echo -e "${GREEN}[java] Already configured. Exiting.${RESET}"
else
    echo -e "${YELLOW}[java] Configuration step started.${RESET}"
    [[ $(cat ~/.bashrc | grep "$expHome") ]] || echo "$expHome" >>~/.bashrc
    [[ $(cat ~/.bashrc | grep "$expPath") ]] || echo "$expPath" >>~/.bashrc
    . ~/.bashrc
    echo -e "${GREEN}[java] Configuration step finished.${GREEN}"

fi
