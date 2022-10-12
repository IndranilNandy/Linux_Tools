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
    case "${2}" in
    --setup)
        echo -e "[NFS][client] setup"
        (cd client && ./nfs_clientside_setup.sh)
        echo -e "[NFS][client] setup done"
        ;;
    --config)
        echo -e "[NFS][client] Configure /etc/.exports"
        echo -e "Run with --refresh option after updating the configuration"
        editor ./config/client/.commons
        editor ./config/client/"$(hostname)-$(hostname -I | awk '{ print $1 }')"
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
