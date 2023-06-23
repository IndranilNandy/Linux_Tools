#!/usr/bin/env bash

echo -e "\n\nStatus of all containers to be setup:"
echo -e "_________________________________________"
cat ./.containers | xargs -I X echo "docker container inspect X > /dev/null 2> /dev/null && printf '%-30s %s\n' X ' :Running' || printf '%-30s %s\n' X ' :NOT Running'" | bash
