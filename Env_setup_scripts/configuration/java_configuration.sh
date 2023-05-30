#!/usr/bin/env bash

javahome=$(update-alternatives --list java | grep "java-18-openjdk-amd64" | head -n1 | sed "s#\(.*\)/bin/java#\1#")
path="$javahome/bin"

envloader="$MYCONFIGLOADER"/.envloader

expHome="export JAVA_HOME=$javahome"
# expPath="export PATH=$PATH:$path"

expPath="export PATH=$PATH"
(echo "$expPath" | grep -E -v " *#" | grep -q "$path") || expPath="$expPath":"$path"

if [[ $(cat "$envloader" | grep "$expHome") ]]; then
    echo -e "${GREEN}[java] Already configured. Exiting.${RESET}"
else
    echo -e "${YELLOW}[java] Configuration step started.${RESET}"
    myshpath add --path="$javahome/bin" --export="JAVA_HOME=$javahome"
    echo -e "${GREEN}[java] Configuration step finished.${GREEN}"
fi
