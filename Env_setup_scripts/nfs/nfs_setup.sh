#!/usr/bin/env bash

# for arg in $*; do
#     case "$arg" in
#     server
# done

case "${1}" in
server)
    case "${2}" in
    --setup)
        echo -e "[NFS][server] setup"
        (cd server && ./nfs_serverside_setup.sh)
        ;;
    --config)
        echo -e "[NFS][server] Configure /etc/.exports"
        echo -e "Run with --refresh option after updating the configuration"
        editor ./config/server/.commons
        editor ./config/server/"$(hostname)-$(hostname -I | awk '{ print $1 }')"
        ;;
    --refresh)
        echo -e "[NFS][server] Rrefresh configuration changes in /etc/.exports"
        (cd server && ./nfs_serverside_configurer.sh)
        ;;
    --uninstall)
        echo -e "[NFS][server] uninstallation"
        (cd server && ./nfs_serverside_uninstaller.sh)
        ;;
    esac
    ;;
client)
    echo client
    ;;
*) ;;
esac
