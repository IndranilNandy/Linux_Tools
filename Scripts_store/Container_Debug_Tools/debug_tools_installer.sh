#!/bin/sh

apk --version 2>/dev/null && pkgMgr=apk
apt --version 2>/dev/null && pkgMgr=apt

case $pkgMgr in
apk)
    echo "apk"
    apk update
    xargs -I X apk add X <./debug_tools.txt
    ;;
apt)
    echo "apt"
    apt update
    xargs -I X apt install -y X <./debug_tools.txt
    ;;
esac

# apt update
# apt install -y iproute2
# apt install -y nmap
# apt install -y iputils-ping
