#!/usr/bin/env bash

case "${1}" in
server)
    case "${2}" in
    --setup)
        echo -e "[NFS][server] setup"
        (cd server && ./nfs_serverside_setup.sh)
        echo -e "[NFS][server] setup done"
        ;;
    --config)
        echo -e "[NFS][server] Configure /etc/.exports"
        editor -w ./config/server/.commons
        editor -w ./config/server/"$(hostname)-$(hostname -I | awk '{ print $1 }')"
        mynfs server --refresh
        ;;
    --refresh)
        echo -e "[NFS][server] Rrefresh configuration changes in /etc/.exports"
        (cd server && ./nfs_serverside_configurer.sh)
        ;;
    --prune)
        echo -e "[NFS][server] Pruning deleted configurations from /etc/.exports"
        sudo cp /etc/exports-backup /etc/exports
        (cd server && ./nfs_serverside_configurer.sh)
        ;;
    --uninstall)
        echo -e "[NFS][server] uninstallation"
        (cd server && ./nfs_serverside_uninstaller.sh)
        ;;
    esac
    ;;
client)
    case "${2}" in
    --setup)
        echo -e "[NFS][client] setup"
        (cd client && ./nfs_clientside_setup.sh)
        echo -e "[NFS][client] setup done"
        ;;
    --config)
        echo -e "[NFS][client] Configure /etc/.exports"
        editor -w ./config/client/.commons
        editor -w ./config/client/"$(hostname)-$(hostname -I | awk '{ print $1 }')"
        mynfs client --refresh
        ;;
    --refresh)
        echo -e "[NFS][client] Adding new updated mounts"
        (cd client && ./nfs_clientside_configurer.sh)
        ;;
    --uninstall)
        echo -e "[NFS][client] uninstallation"
        (cd client && ./nfs_clientside_uninstaller.sh)
        ;;
    esac
    ;;
--help)
    cat ./help/mynfs.help
    ;;
*) ;;
esac
