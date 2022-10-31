#!/usr/bin/env bash

client_node="${1}"

echo -e "\n[CLIENT CONFIGURATION] SETUP WILL NOW CONFIGURE CLIENT NODE: $client_node"
user=$(cat ./config/.machineconfig | grep -i "$client_node:" | sed "s/$client_node: *\(.*\)/\1/I" | tr " *" "\n" | xargs -I X echo X)

. ./lib/loadCred.lib "$user" "$client_node"


! sshpass -p "$passwd" scp -o 'StrictHostKeyChecking no' -r ~/MyTools/Linux_Tools/Dev_tools_setup_scripts/k8 "$user"@"$client_node":~ && echo -e "[CLIENT CONFIGURATION] Failed to copy codebase to client node $client_node" && exit 1
! sshpass -p "$passwd" ssh -o 'StrictHostKeyChecking no' -t "$user"@"$client_node" "cd ~/k8; export psdsource=$psdsource; export k8_tear_allnodes=$k8_tear_allnodes; echo $passwd | sudo -S echo "entered"; bash --login ./nodes/clients/client_configurer.sh" && echo -e "[CLIENT CONFIGURATION] FAILED!! Configuration NOT completed in clien node $client_node" && exit 1

exit 0