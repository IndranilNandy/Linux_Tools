#!/bin/bash

if [[ -z $(which myinstaller) ]]; then
    curDir=$(pwd)
else
    curDir=$(dirname "$(tracelink "$(which myinstaller)")")
fi

localList=$curDir"/.localAptPkgTools"
[[ -e $localList ]] || touch $localList

localSnapList=$curDir"/.localSnapPkgTools"
[[ -e $localSnapList ]] || touch $localSnapList

fullList=$curDir"/.fullAptPkgTools"
fullSnapList=$curDir"/.fullSnapPkgTools"
export curDir

tool="apt"

case ${1} in
--install)
    sudo apt update
    case ${2} in
    --FULL)
        cat $fullList | xargs -I X echo "[[ \$(ifinstalled X) ]] || ( echo "Installing X using APT" && ( yes | sudo apt install X ) && ( [[ \$(cat $localList | grep X) ]] || echo X >> $localList ) )" | bash
        cat $fullSnapList | xargs -I X echo "[[ \$(ifinstalled X) ]] || ( echo "Installing X using SNAP" && ( yes | sudo snap install X ) && ( [[ \$(cat $localSnapList | grep X) ]] || echo X >> $localSnapList ) )" | bash
        ;;
    --LOCAL)
        # cat $localList | xargs -I X echo "[[ \$(ifinstalled X) ]] || ( echo "Installing X" && ( yes | sudo apt install X ) )" | bash
        [[ ${3} ]] && cat ${3} | xargs -I X echo "[[ \$(ifinstalled X) ]] || \
                        ( echo "Installing X using APT" && \
                            ( yes | sudo apt install X  && \
                                ( [[ \$(cat $localList | grep X) ]] || echo X >> $localList )  && \
                                ( [[ \$(cat $fullList | grep X) ]] || echo X >> $fullList ) \
                            ) \
                        ) || \
                        ( echo "Installing X using SNAP" && \
                            ( yes | sudo snap install X  && \
                                ( [[ \$(cat $localSnapList | grep X) ]] || echo X >> $localSnapList )  && \
                                ( [[ \$(cat $fullSnapList | grep X) ]] || echo X >> $fullSnapList ) \
                            ) \
                        )" |
            bash
        ;;
    *)
        echo "[[ \$(ifinstalled ${2}) ]] || \
                        ( echo "Installing ${2} using APT" && \
                            ( yes | sudo apt install ${2}  && \
                                ( [[ \$(cat $localList | grep ${2}) ]] || echo ${2} >> $localList )  && \
                                ( [[ \$(cat $fullList | grep ${2}) ]] || echo ${2} >> $fullList ) \
                            ) \
                        ) || \
                        ( echo "Installing ${2} using SNAP" && \
                            ( yes | sudo snap install ${2}  && \
                                ( [[ \$(cat $localSnapList | grep ${2}) ]] || echo ${2} >> $localSnapList )  && \
                                ( [[ \$(cat $fullSnapList | grep ${2}) ]] || echo ${2} >> $fullSnapList ) \
                            ) \
                        )" |
            bash
        ;;
    esac
    xargs -I X echo "grep -q X  \"\$curDir\"/../../_verify/.allTools || echo \"X:X\" >> \"\$curDir\"/../../_verify/.allTools" <"$localList" | bash
    ;;
--uninstall)
    case ${2} in
    --FULL)
        cat $localList | xargs -I X echo "[[ \$(ifinstalled X) ]] && ( echo "Uninstalling X using APT" && ( yes | sudo apt remove X ) && sed -i /^X$/d $localList )" | bash
        cat $localSnapList | xargs -I X echo "[[ \$(ifinstalled X) ]] && ( echo "Uninstalling X using SNAP" && ( yes | sudo snap remove X ) && sed -i /^X$/d $localSnapList )" | bash
        ;;
    --LOCAL)
        [[ ${3} ]] && cat ${3} | xargs -I X echo "[[ \$(ifinstalled X) ]] && ( echo "Uninstalling X using APT" && ( yes | sudo apt remove X ) && sed -i /^X$/d $localList )" | bash
        [[ ${3} ]] && cat ${3} | xargs -I X echo "[[ \$(ifinstalled X) ]] && ( echo "Uninstalling X using SNAP" && ( yes | sudo snap remove X ) && sed -i /^X$/d $localSnapList )" | bash
        ;;
    *)
        echo "[[ \$(ifinstalled ${2}) ]] && ( echo "Uninstalling ${2} using APT" && ( yes | sudo apt remove ${2} ) && sed -i /^${2}$/d $localList )" | bash
        echo "[[ \$(ifinstalled ${2}) ]] && ( echo "Uninstalling ${2} using SNAP" && ( yes | sudo snap remove ${2} ) && sed -i /^${2}$/d $localSnapList )" | bash
        ;;
    esac
    sudo apt clean
    yes | sudo apt autoremove
    xargs -I X echo "grep -q X  \"\$curDir\"/../../_verify/.allTools || echo \"X:X\" >> \"\$curDir\"/../../_verify/.allTools" <"$localList" | bash
    ;;
--list)
    cat $localList | xargs -I X echo "[[ \$(ifinstalled X) ]] && printf \"%-10s %s %s\n\" \"APT\" \": Already installed\" 'X' " | bash
    cat $localSnapList | xargs -I X echo "[[ \$(ifinstalled X) ]] && printf \"%-10s %s %s\n\" \"SNAP\" \": Already installed\" 'X' " | bash
    ;;
--help)
    cat $curDir/myinstaller.help
    ;;
*)
    cat $curDir/myinstaller.help
    ;;
esac

xargs -I X echo "grep -q X  $curDir/../../_verify/.allTools || ( echo X >> $localList && echo \"X:X\" >> $curDir/../../_verify/.allTools )" < $fullList | bash
xargs -I X echo "grep -q X  $curDir/../../_verify/.allTools || ( echo X >> $localSnapList && echo \"X:X\" >> $curDir/../../_verify/.allTools )" < $fullSnapList | bash
