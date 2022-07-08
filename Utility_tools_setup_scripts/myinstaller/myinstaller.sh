#!/bin/bash

if [[ -z $(which myinstaller) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which myinstaller)")")
fi

localList=$curDir"/.localAptPkgTools"
[[ -e $localList ]] || touch $localList

fullList=$curDir"/.fullAptPkgTools"

case ${1} in
    --install)
        sudo apt update
        case ${2} in
            --FULL)
                cat $fullList | xargs -I X echo "[[ \$(ifinstalled X) ]] || ( echo "Installing X" && ( yes | sudo apt install X ) && ( [[ \$(cat $localList | grep X) ]] || echo X >> $localList ) )" | bash
                ;;
            --LOCAL)
                # cat $localList | xargs -I X echo "[[ \$(ifinstalled X) ]] || ( echo "Installing X" && ( yes | sudo apt install X ) )" | bash
                [[ ${3} ]] && cat ${3} | xargs -I X echo "[[ \$(ifinstalled X) ]] || \
                        ( echo "Installing X" && \
                            ( yes | sudo apt install X  && \
                                ( [[ \$(cat $localList | grep X) ]] || echo X >> $localList )  && \
                                ( [[ \$(cat $fullList | grep X) ]] || echo X >> $fullList ) \
                            ) \
                        )" \
                    | bash
                ;;
            *)
                echo "[[ \$(ifinstalled ${2}) ]] || \
                        ( echo "Installing ${2}" && \
                            ( yes | sudo apt install ${2}  && \
                                ( [[ \$(cat $localList | grep ${2}) ]] || echo ${2} >> $localList )  && \
                                ( [[ \$(cat $fullList | grep ${2}) ]] || echo ${2} >> $fullList ) \
                            ) \
                        )" \
                    | bash
                ;;
        esac
        ;;
    --uninstall)
        case ${2} in
            --FULL)
                cat $localList | xargs -I X echo "[[ \$(ifinstalled X) ]] && ( echo "Uninstalling X" && ( yes | sudo apt remove X ) && sed -i /^X$/d $localList )" | bash
                ;;
            --LOCAL)
                [[ ${3} ]] && cat ${3} | xargs -I X echo "[[ \$(ifinstalled X) ]] && ( echo "Uninstalling X" && ( yes | sudo apt remove X ) && sed -i /^X$/d $localList )" | bash
                ;;
            *)
                echo "[[ \$(ifinstalled ${2}) ]] && ( echo "Uninstalling ${2}" && ( yes | sudo apt remove ${2} ) && sed -i /^${2}$/d $localList )" | bash
                ;;
        esac
        sudo apt clean
        yes | sudo apt autoremove
        ;;
    --list)
        cat $localList | xargs -I X echo "[[ \$(ifinstalled X) ]] && echo "Already installed X" " | bash
        ;;
    --help)
        cat $curDir/myinstaller.help
        ;;
    *)
        cat $curDir/myinstaller.help
        ;;
esac