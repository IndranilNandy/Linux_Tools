#!/usr/bin/env bash

ippattern='IPADDR'
ipaddr=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

maskpattern='MASK'
mask=$(ip -4 addr show eth0 | grep -oP '(?<=/)\d+')

gatewaypattern='GATEWAYADDR'
gatewayaddr=$(ip r | grep -oP '(?<=default\svia\s)\d+(\.\d+){3}')

templatefile="./configs/01-netcfg-template.yaml"

[ ! -e "/etc/netplan/01-netcfg.yaml.bak" ] && [ -e "/etc/netplan/01-netcfg.yaml" ] && sudo cp /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.bak
sed -e "s/$ippattern/$ipaddr/g" -e "s/$maskpattern/$mask/g" -e "s/$gatewaypattern/$gatewayaddr/g" $templatefile | sudo tee /etc/netplan/01-netcfg.yaml > /dev/null

sudo netplan apply
ip a