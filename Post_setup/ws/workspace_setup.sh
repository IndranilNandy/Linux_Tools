#!/usr/bin/env bash

if [[ -L $(which ws) ]]; then
    curDir="$(dirname "$(tracelink ws)")"
else
    curDir="$(pwd)"
fi

# commandsDir="$curDir"/commands
. "$curDir"/../../.systemConfig

load_ws() {
    sno="${1}"
    top_padding=3

    echo -e "Opening in a new sub shell. Press Ctrl+d or type 'exit' to exit or go back to the previous shell."
    cd "$user_devroot"/"$repo_root"/$(cat "$curDir"/config/.wsConfig | head -"$((sno + top_padding))" | tail -1 | awk '{ print $5 }')

    # The following works and hence NOT removed. Let it be there for any future reference
    #         instl_script=" source ~/.bashrc; \
    # qcd --help; \
    # exit 0 "

    #     bash --init-file <(echo "$instl_script;")

    $SHELL
}

show_ws_status() {
    echo -e "#######################################"
    echo -e "SerialNo------->LocalRepo------->Status"
    echo -e "#######################################\n"
    nl -w2 -s'. ' <(
        grep -v "^ *#" <"$curDir"/config/.wsConfig | xargs -I X echo X | awk '{ print $5 }' |
            xargs -I X echo "printf \"%-150s\" "$user_devroot"/"$repo_root"/X; (cd "$user_devroot"/"$repo_root"/X 2> /dev/null && \
        (((git status | grep -E -q \"Changes not staged|Untracked files\") && echo -e \"\t\e[31mUNCOMMITED changes exist\e[0m\" ) \
        || echo -e \"\t\e[32mUP-TO-DATE\e[0m\")) || echo -e \"\trepo not downloaded\"" | bash
    )
}

configure_qcd_wsmappings() {
    instl_script=" source ~/.bashrc; \
qcd --wsconfig; \
exit 0 "

    bash --init-file <(echo "$instl_script;")
}

case ${1} in
--config)
    editor -w "$curDir"/config/.wsConfig
    configure_qcd_wsmappings
    ;;
--clone)
    "$curDir"/workspace_clone.sh "$@"
    ;;
--list)
    cat "$curDir"/config/.wsConfig
    ;;
--load)
    [[ -z "${2}" ]] && echo -e "Missing SerialNo as the second argument, check 'ws --help'" && exit 1
    load_ws "${2}"
    ;;
--status)
    show_ws_status
    ;;
# backup)
#     "$curDir"/workspace_backup.sh "$@"
#     ;;
# list)
#     "$curDir"/workspace_listpatches.sh "$@"
#     ;;
# restore)
#     "$curDir"/workspace_restore.sh "$@"
#     ;;
# sync)
#     "$curDir"/workspace_syncpoints.sh "$@"
#     ;;
# restore)
#     "$curDir"/workspace_restore.sh "$@"
#     ;;
--help)
    cat "$curDir"/help/ws.help
    ;;
*)
    cat "$curDir"/help/ws.help
    ;;
esac
