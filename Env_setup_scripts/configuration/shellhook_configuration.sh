#!/bin/bash

[[ -f $MYCONFIGLOADER/.bash-preexec.sh ]] && echo -e "[shellhook] Already exists" && exit 0

# Pull down our file from GitHub and write it to your home directory as a hidden file.
curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o "$MYCONFIGLOADER"/.bash-preexec.sh
# Source our file at the end of our bash profile (e.g. ~/.bashrc, ~/.profile, or ~/.bash_profile)
[[ $(cat ~/.bashrc | grep -E -v " *#" | grep "$MYCONFIGLOADER/.bash-preexec.sh") ]] || echo "[[ -f $MYCONFIGLOADER/.bash-preexec.sh ]] && source $MYCONFIGLOADER/.bash-preexec.sh" >> ~/.bashrc