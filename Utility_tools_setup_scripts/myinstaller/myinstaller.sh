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

localNpmList=$curDir"/.localNpmPkgTools"
[[ -e $localNpmList ]] || touch $localNpmList

fullList=$curDir"/.fullAptPkgTools"
fullSnapList=$curDir"/.fullSnapPkgTools"
fullNpmList=$curDir"/.fullNpmPkgTools"

export curDir

tool="apt"

case ${1} in
--install)
    sudo apt update
    case ${2} in
    --FULL)
        cat $fullList | xargs -I X echo "[[ \$(ifinstalled X) ]] || ( echo "Installing X using APT" && ( yes | sudo apt install X ) && ( [[ \$(cat $localList | grep -x X) ]] || echo X >> $localList ) )" | bash
        cat $fullSnapList | xargs -I X echo "[[ \$(ifinstalled X) ]] || ( echo "Installing X using SNAP" && ( yes | sudo snap install X ) && ( [[ \$(cat $localSnapList | grep -x X) ]] || echo X >> $localSnapList ) )" | bash
        cat $fullNpmList | xargs -I X echo "[[ \$(ifinstalled X) ]] || ( echo "Installing X using NPM" && ( yes | sudo npm install -g X ) && ( [[ \$(cat $localNpmList | grep -x X) ]] || echo X >> $localNpmList ) )" | bash
        ;;
    --LOCAL)
        # cat $localList | xargs -I X echo "[[ \$(ifinstalled X) ]] || ( echo "Installing X" && ( yes | sudo apt install X ) )" | bash
        [[ ${3} ]] && cat ${3} | xargs -I X echo "[[ \$(ifinstalled X) ]] || \
                        ( echo "Installing X using APT" && \
                            ( yes | sudo apt install X  && \
                                ( [[ \$(cat $localList | grep -x X) ]] || echo X >> $localList )  && \
                                ( [[ \$(cat $fullList | grep -x X) ]] || echo X >> $fullList ) \
                            ) \
                        ) || \
                        ( echo "Installing X using SNAP" && \
                            ( yes | sudo snap install X  && \
                                ( [[ \$(cat $localSnapList | grep -x X) ]] || echo X >> $localSnapList )  && \
                                ( [[ \$(cat $fullSnapList | grep -x X) ]] || echo X >> $fullSnapList ) \
                            ) \
                        ) || \
                        ( echo "Installing X using NPM" && \
                            ( yes | sudo npm install -g X  && \
                                ( [[ \$(cat $localNpmList | grep -x X) ]] || echo X >> $localNpmList )  && \
                                ( [[ \$(cat $fullNpmList | grep -x X) ]] || echo X >> $fullNpmList ) \
                            ) \
                        )" |
            bash
        ;;
    *)
        echo "[[ \$(ifinstalled ${2}) ]] || \
                        ( echo "Installing ${2} using APT" && \
                            ( yes | sudo apt install ${2}  && \
                                ( [[ \$(cat $localList | grep -x ${2}) ]] || echo ${2} >> $localList )  && \
                                ( [[ \$(cat $fullList | grep -x ${2}) ]] || echo ${2} >> $fullList ) \
                            ) \
                        ) || \
                        ( echo "Installing ${2} using SNAP" && \
                            ( yes | sudo snap install ${2}  && \
                                ( [[ \$(cat $localSnapList | grep -x ${2}) ]] || echo ${2} >> $localSnapList )  && \
                                ( [[ \$(cat $fullSnapList | grep -x ${2}) ]] || echo ${2} >> $fullSnapList ) \
                            ) \
                        ) || \
                        ( echo "Installing ${2} using NPM" && \
                            ( yes | sudo npm install -g ${2}  && \
                                ( [[ \$(cat $localNpmList | grep -x ${2}) ]] || echo ${2} >> $localNpmList )  && \
                                ( [[ \$(cat $fullNpmList | grep -x ${2}) ]] || echo ${2} >> $fullNpmList ) \
                            ) \
                        )" |
            bash
        ;;
    esac
    xargs -I X echo "grep -q X:X  \"\$curDir\"/../../_verify/.allTools || echo \"X:X\" >> \"\$curDir\"/../../_verify/.allTools" <"$localList" | bash
    xargs -I X echo "grep -q X:X  \"\$curDir\"/../../_verify/.allTools || echo \"X:X\" >> \"\$curDir\"/../../_verify/.allTools" <"$localSnapList" | bash
    xargs -I X echo "grep -q X:X  \"\$curDir\"/../../_verify/.allTools || echo \"X:X\" >> \"\$curDir\"/../../_verify/.allTools" <"$localNpmList" | bash

    ;;
--uninstall)
    case ${2} in
    --FULL)
        cat $localList | xargs -I X echo "[[ \$(ifinstalled X) ]] && ( echo "Uninstalling X using APT" && ( yes | sudo apt remove X ) && sed -i /^X$/d $localList )" | bash
        cat $localSnapList | xargs -I X echo "[[ \$(ifinstalled X) ]] && ( echo "Uninstalling X using SNAP" && ( yes | sudo snap remove X ) && sed -i /^X$/d $localSnapList )" | bash
        cat $localNpmList | xargs -I X echo "[[ \$(ifinstalled X) ]] && ( echo "Uninstalling X using NPM" && ( yes | sudo npm uninstall -g X ) && sed -i /^X$/d $localNpmList )" | bash
        ;;
    --LOCAL)
        [[ ${3} ]] && cat ${3} | xargs -I X echo "[[ \$(ifinstalled X) ]] && ( echo "Uninstalling X using APT" && ( yes | sudo apt remove X ) && sed -i /^X$/d $localList )" | bash
        [[ ${3} ]] && cat ${3} | xargs -I X echo "[[ \$(ifinstalled X) ]] && ( echo "Uninstalling X using SNAP" && ( yes | sudo snap remove X ) && sed -i /^X$/d $localSnapList )" | bash
        [[ ${3} ]] && cat ${3} | xargs -I X echo "[[ \$(ifinstalled X) ]] && ( echo "Uninstalling X using NPM" && ( yes | sudo npm uninstall -g X ) && sed -i /^X$/d $localNpmList )" | bash
        ;;
    *)
        echo "[[ \$(ifinstalled ${2}) ]] && ( echo "Uninstalling ${2} using APT" && ( yes | sudo apt remove ${2} ) && sed -i /^${2}$/d $localList )" | bash
        echo "[[ \$(ifinstalled ${2}) ]] && ( echo "Uninstalling ${2} using SNAP" && ( yes | sudo snap remove ${2} ) && sed -i /^${2}$/d $localSnapList )" | bash
        echo "[[ \$(ifinstalled ${2}) ]] && ( echo "Uninstalling ${2} using NPM" && ( yes | sudo npm uninstall -g ${2} ) && sed -i /^${2}$/d $localNpmList )" | bash
        ;;
    esac
    sudo apt clean
    yes | sudo apt autoremove

    # TODO: Need to check more if this is necessary
    xargs -I X echo "grep -q X  \"\$curDir\"/../../_verify/.allTools || echo \"X:X\" >> \"\$curDir\"/../../_verify/.allTools" <"$localList" | bash
    ;;
--list)
    cat $localList | xargs -I X echo "[[ \$(ifinstalled X) ]] && printf \"%-10s %s %s\n\" \"APT\" \": Already installed\" 'X' " | bash
    cat $localSnapList | xargs -I X echo "[[ \$(ifinstalled X) ]] && printf \"%-10s %s %s\n\" \"SNAP\" \": Already installed\" 'X' " | bash
    cat $localNpmList | xargs -I X echo "[[ \$(ifinstalled X) ]] && printf \"%-10s %s %s\n\" \"NPM\" \": Already installed\" 'X' " | bash
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
xargs -I X echo "grep -q X  $curDir/../../_verify/.allTools || ( echo X >> $localNpmList && echo \"X:X\" >> $curDir/../../_verify/.allTools )" < $fullNpmList | bash

