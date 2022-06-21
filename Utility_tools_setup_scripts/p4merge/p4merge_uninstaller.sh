#!/bin/bash
[[ -d /opt/p4v ]] && sudo rm -rf /opt/p4v
[[ -h /usr/local/bin/p4merge ]] && sudo rm /usr/local/bin/p4merge