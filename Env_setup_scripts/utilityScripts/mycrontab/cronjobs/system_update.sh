#!/usr/bin/env bash

# NOTE:
# } >> >(ts '[%Y-%m-%d %H:%M:%S]' >>/home/indranilnandy/MyTools/Linux_Tools/Post_setup/crontab/cronlogs/system_update.log) - NOT working for root/user, though ts is available and working
# } >> >(ts >>/home/indranilnandy/MyTools/Linux_Tools/Post_setup/crontab/cronlogs/system_update.log) - NOT working for root/user, though ts is available and working
# } >> /home/indranilnandy/MyTools/Linux_Tools/Post_setup/crontab/cronlogs/system_update.log - WORKING for root/user
# } >> >(ts '[%Y-%m-%d %H:%M:%S]' >>"$(dirname "$BASH_SOURCE")/../cronlogs/$(basename "$BASH_SOURCE" .sh)".log) -NOT working for root/user (empty BASH_SOURCE), but WORKING when the script is run manually

echo "Running 'apt update'" | ts '[%Y-%m-%d %H:%M:%S]'
apt update | ts '[%Y-%m-%d %H:%M:%S]'
echo "Completed 'apt update'" | ts '[%Y-%m-%d %H:%M:%S]'
echo

echo "Running 'apt upgrade'" | ts '[%Y-%m-%d %H:%M:%S]'
yes | apt upgrade | ts '[%Y-%m-%d %H:%M:%S]'
echo "Completed 'apt upgrade'" | ts '[%Y-%m-%d %H:%M:%S]'
echo

echo "Running 'apt autoremove'" | ts '[%Y-%m-%d %H:%M:%S]'
yes | apt autoremove | ts '[%Y-%m-%d %H:%M:%S]'
echo "Completed 'apt autoremove'" | ts '[%Y-%m-%d %H:%M:%S]'
echo

echo "#####################DONE#####################"
echo
echo