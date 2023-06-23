#!/usr/bin/env bash

# export DISPLAY=:0.0
echo "Running script" | ts '[%Y-%m-%d %H:%M:%S]'
date | ts
# /usr/bin/gnome-terminal --window -e "echo testing"
# source /home/indranilnandy/.bashrc
export PATH="$PATH":/usr/local/bin/mycommands:/usr/local/bin/myscriptrefs
ws --help
qcd --help
# /home/indranilnandy/MyTools/Linux_Tools/Setup_stages/Automated_post_setup/mycrontab/cronjobs/test.sh
# /home/indranilnandy/MyTools/Linux_Tools/Setup_stages/Automated_post_setup/ws_setup/workspace_setup.sh --help
echo "bash_source=$BASH_SOURCE"
echo "env=$(env) pwd=$(pwd)"
echo "Completed script" | ts '[%Y-%m-%d %H:%M:%S]'
echo

echo "#####################DONE#####################"
echo
echo
