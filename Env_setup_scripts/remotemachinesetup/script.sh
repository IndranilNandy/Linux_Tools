sshpass -p $cred ssh -o 'StrictHostKeyChecking no' -t $userhost ls
sshpass -p $cred ssh -o 'StrictHostKeyChecking no' -t $userhost whoami