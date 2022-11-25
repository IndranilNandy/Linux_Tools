#!/usr/bin/env bash

echo "Running script" | ts '[%Y-%m-%d %H:%M:%S]'
date | ts
source /home/indranilnandy/.bashrc
export PATH="$PATH":/usr/local/bin/mycommands
ws --help
# /home/indranilnandy/MyTools/Linux_Tools/Post_setup/mycrontab/cronjobs/test.sh
# /home/indranilnandy/MyTools/Linux_Tools/Post_setup/ws_setup/workspace_setup.sh --help
echo "bash_source=$BASH_SOURCE"
echo "env=$(env) pwd=$(pwd)"
echo "Completed script" | ts '[%Y-%m-%d %H:%M:%S]'
echo

echo "#####################DONE#####################"
echo
echo
