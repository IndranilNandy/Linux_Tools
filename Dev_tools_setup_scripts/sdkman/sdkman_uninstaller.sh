#!/usr/bin/env bash

tar zcvf ~/sdkman-backup_$(date +%F-%kh%M).tar.gz -C ~/ .sdkman
rm -rf ~/.sdkman

pattern='#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!'
sed -i "/^$pattern$/d" ~/.bashrc

pattern='export SDKMAN_DIR="$HOME/.sdkman"'
sed -i "\,^$pattern$,d" ~/.bashrc

pattern='\[\[ -s "$HOME/.sdkman/bin/sdkman-init.sh" \]\] && source "$HOME/.sdkman/bin/sdkman-init.sh"'
sed -i "\,^$pattern$,d" ~/.bashrc
