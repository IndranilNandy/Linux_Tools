#!/usr/bin/env bash

echo "Running script" | ts '[%Y-%m-%d %H:%M:%S]'

# source /home/indranilnandy/.bashrc

[[ -e /home/indranilnandy/.myconfig/.configloader/.envloader ]] && source /home/indranilnandy/.myconfig/.configloader/.envloader
export SDKMAN_DIR="/home/indranilnandy/.sdkman"
[[ -s "/home/indranilnandy/.sdkman/bin/sdkman-init.sh" ]] && source "/home/indranilnandy/.sdkman/bin/sdkman-init.sh"

sdk update
echo "Completed." | ts '[%Y-%m-%d %H:%M:%S]'

echo "#####################DONE#####################"
echo
