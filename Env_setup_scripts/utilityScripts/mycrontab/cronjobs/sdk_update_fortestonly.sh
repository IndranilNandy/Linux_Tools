#!/usr/bin/env bash

# sdk update

echo "Running script" | ts '[%Y-%m-%d %H:%M:%S]'

env
# source /home/indranilnandy/.bashrc
. /home/indranilnandy/.bashrc
[[ -e /home/indranilnandy/.myconfig/.configloader/.envloader ]] && source /home/indranilnandy/.myconfig/.configloader/.envloader
export SDKMAN_DIR="/home/indranilnandy/.sdkman"
[[ -s "/home/indranilnandy/.sdkman/bin/sdkman-init.sh" ]] && source "/home/indranilnandy/.sdkman/bin/sdkman-init.sh"

echo "@2"
env
# source /Users/indranilnandy/.bashrc
export PATH="$PATH":/usr/local/bin/mycommands:/usr/local/bin/myscriptrefs
# export PATH="$PATH":/usr/local/bin/mycommands:/usr/local/bin/myscriptrefs

instl_script=" source /home/indranilnandy/.bashrc; \
    source /home/indranilnandy/.myconfig/.configloader/.envloader \
    export SDKMAN_DIR=\"/home/indranilnandy/.sdkman\" \
    source /home/indranilnandy/.sdkman/bin/sdkman-init.sh \
    touch /home/indranilnandy/test123; \
    sdk update >> /home/indranilnandy/test123; \
    echo testing >> /home/indranilnandy/test123; \
    exit 0 "

bash --init-file <(echo "$instl_script;")
ws --help
qcd --help
sdk update
echo "here path=$PATH"
echo "here"
env
echo "var=$MYCONFIGLOADER"