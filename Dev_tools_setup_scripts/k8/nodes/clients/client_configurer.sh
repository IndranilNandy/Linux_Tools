#!/usr/bin/env bash

# kubectl setup
! ./components/kubectl/kubectl_installer.sh && echo -e "[CLIENT CONFIGURATION] Issue with kubectl installation" && exit 1

node_c=$(cat ./config/.clusterconfig | grep "controlplane:" | sed "s/controlplane: *\(.*\)/\1/" | tr " *" "\n" | xargs -I X echo X)
user_c=$(cat ./config/.machineconfig | grep -i "$node_c:" | sed "s/$node_c: *\(.*\)/\1/I" | tr " *" "\n" | xargs -I X echo X)
echo "user_c: $user_c"

local_client=$(hostname)
user_l=$(cat ./config/.machineconfig | grep -i "$local_client:" | sed "s/$local_client: *\(.*\)/\1/I" | tr " *" "\n" | xargs -I X echo X)
echo "user_l: $user_l"


! ssh -o 'StrictHostKeyChecking no' -t "$user_c"@"$node_c" "sudo scp /etc/kubernetes/admin.conf $user_l@$local_client:~" && echo -e "[CLIENT CONFIGURATION] Failed to get admin.conf from $node_c to $local_client" && exit 1

# Copy to client machines .kube/config
# Ref. https://stackoverflow.com/questions/40447295/how-to-configure-kubectl-with-cluster-information-from-a-conf-file

[[ -d "$HOME/.kube" ]] || mkdir "$HOME/.kube"
cp "$HOME/admin.conf" "$HOME/.kube/config"
kubectl get nodes --all-namespaces