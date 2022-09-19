#!/usr/bin/env bash

javahome=$(update-alternatives --list java | grep "java-18-openjdk-amd64" | head -n1 | sed "s#\(.*\)/bin/java#\1#")
path="$javahome/bin"

envloader="$MYCONFIGLOADER"/.envloader

expHome="export JAVA_HOME=$javahome"
expPath="export PATH=$PATH:$path"

if [[ $( cat "$envloader" | grep "$expHome") ]]; then
    echo -e "${GREEN}[java] Already configured. Exiting.${RESET}"
else
    echo -e "${YELLOW}[java] Configuration step started.${RESET}"
    [[ $(cat "$envloader" | grep "$expHome") ]] || echo "$expHome" >>"$envloader"
    [[ $(cat "$envloader" | grep "$expPath") ]] || echo "$expPath" >>"$envloader"
    . ~/.bashrc
    echo -e "${GREEN}[java] Configuration step finished.${GREEN}"

fi