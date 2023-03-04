#!/usr/bin/env bash

# installer() {
#     mkdir tmp
#     (
#         cd tmp || return

#         wget -O jetbrains-toolbox.tar.gz 'https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.26.5.13419.tar.gz?_gl=1*osexsu*_ga*MTI4NTEwNTg0Ny4xNjY4MDA3NDAw*_ga_9J976DJZ68*MTY2ODA5NDk1MS4zLjEuMTY2ODA5ODM2MS4wLjAuMA..&_ga=2.35392354.2103269660.1668007400-1285105847.1668007400'
#         # sudo dpkg -i cri-dockerd_0.2.5.3-0.ubuntu-jammy_amd64.deb
#         # sudo mkdir -p /op
#         sudo tar -xzf jetbrains-toolbox.tar.gz -C /opt
#     )
#     # rm -rf tmp
# }

# installer

# Source: https://github.com/nagygergo/jetbrains-toolbox-install/blob/master/jetbrains-toolbox.sh

[ $(id -u) != "0" ] && exec sudo "$0" "$@"
echo -e " \e[94mInstalling Jetbrains Toolbox\e[39m"
echo ""

function getLatestUrl() {
USER_AGENT=('User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36')

URL=$(curl 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' -H 'Origin: https://www.jetbrains.com' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.8' -H "${USER_AGENT[@]}" -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: https://www.jetbrains.com/toolbox/download/' -H 'Connection: keep-alive' -H 'DNT: 1' --compressed | grep -Po '"linux":.*?[^\\]",' | awk -F ':' '{print $3,":"$4}'| sed 's/[", ]//g')
echo "$URL"
}
getLatestUrl

FILE=$(basename "${URL}")
DEST=$PWD/$FILE

echo ""
echo -e "\e[94mDownloading Toolbox files \e[39m"
echo ""
wget -cO  "${DEST}" "${URL}" --read-timeout=5 --tries=0
echo ""
echo -e "\e[32mDownload complete!\e[39m"
echo ""
DIR="/opt/jetbrains-toolbox"
echo ""
echo  -e "\e[94mInstalling to $DIR\e[39m"
echo ""
if mkdir ${DIR}; then
    tar -xzf "${DEST}" -C ${DIR} --strip-components=1
fi

chmod -R +rwx ${DIR}

yes | ln -s -i ${DIR}/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox
chmod -R +rwx /usr/local/bin/jetbrains-toolbox
echo ""
rm "${DEST}"
echo  -e "\e[32mDone.\e[39m"

jetbrains-toolbox
